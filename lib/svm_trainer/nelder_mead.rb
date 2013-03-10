require_relative 'base'
module SvmTrainer
  #
  # Trainer for a parmeter search using the Nelder-Mead Simplex heurisitc with the RBF kernel
  #
  # @author Andreas Eger
  #
  class NelderMead < Base
    # default number of iterations to use during parameter search
    DEFAULT_MAX_ITERATIONS=20
    def name
      "Nelder-Mead Simplex Heuristic with #{number_of_folds}-fold cross validation"
    end
    def label
      "nelder_mead"
    end

    def initialize args
      super
      @simplex = []
      @iterations = 0
    end

    #
    # perform a search on the provided feature vectors
    # @param  feature_vectors
    #
    # @return [model, results] trained svm model and the results of the search
    def search feature_vectors, max_iterations=DEFAULT_MAX_ITERATIONS
      super(feature_vectors)
      @max_iterations = max_iterations

      initial_simplex
      loop do
        best, worse, worst = order
        #TODO this line looks ugly, fix it
        center = ParameterSet.new *[best,worse].map(&:to_a).transpose.map{|e| e.inject(&:+)/e.length.to_f}
        reflection = reflect center, worst
        case
        when best >= reflection && reflection >= worse
          worst = reflection
        when reflection > best
          expansion = expand center, worst
          if expansion > reflection
            worst = expansion
          else
            worst = reflection
          end
        when reflection < worse
          contraction = if reflection < worst
                          contract_outside(center, worst)
                        else
                          contract_inside(center, worst)
                        end
          if contraction > worst
            worst = contraction
          else
            worse, worst = [worse, worst].map { |e| contract_inside(best, e) }
          end
        end
        @simplex = [best, worse, worst]
        break if done?
      end

      # get the pair with the best value
      best_parameter = ParameterSet.from_key results.invert[results.values.max]

      # binding.pry
      model = train_svm feature_vectors, best_parameter
      return model, results, best_parameter
    end

    #
    # create a initial simplex (with n=3)
    # @param  x1 ParameterSet one point
    # @param  c Number edge length
    #
    # @return [Array<ParameterSet>] 3 points in form of a regular triangle
    def initial_simplex(x1=ParameterSet.new(-4.0,-4.0),c=8)
      p= c/Math.sqrt(2) * (Math.sqrt(3)-1)/2
      q= ParameterSet.new(p,p)
      x2 = x1 + q + ParameterSet.new(1.0,0.0) * (c/Math.sqrt(2))
      x3 = x1 + q + ParameterSet.new(0.0,1.0) * (c/Math.sqrt(2))
      @simplex = [x1,x2,x3]
    end

    def order
      @simplex.each { |e| e.result = func(e) } # calculate results
      @simplex.sort!
      @simplex.reverse!
      return [ @simplex[0], @simplex[-2], @simplex[-1] ]
    end

    #
    # creates a new ParameterSet which is a reflection of the point around a center
    # @param  center ParameterSet reflection center
    # @param  point ParameterSet point to reflect
    # @param  alpha Number factor to extend or contract the reflection
    #
    # @return [ParameterSet] reflected ParameterSet
    def reflect(center, point, alpha=1.0)
      #center.map.with_index{|e,i| e + alpha * ( e - point[i] )} # version for simple arrays
      p = center + ( center - point ) * alpha
      p.result = func(p)
      p
    end

    #
    # creates a extended reflected ParameterSet
    # (see #reflect)
    def expand(center, point, beta=2.0)
      reflect center, point, beta
    end

    #
    # creates a contracted reflected ParameterSet
    # (see #reflect)
    def contract_outside(center, point, gamma=0.5)
      reflect center, point, gamma
    end

    #
    # creates a contracted reflected ParameterSet
    # (see #reflect)
    def contract_inside(center, point, gamma=0.5)
      p = center + ( point - center ) * gamma
      p.result = func(p)
      p
    end

    TOLERANCE=10**-2
    #TODO find something better to do here, this either stops to early or will never stop depending on the data
    def done?
      p "iteration: #{@iterations += 1}"
      return true if @iterations >= @max_iterations
      return false unless @simplex.permutation(2).map { |e|
          l = Math.sqrt((e[0] - e[1]).to_a.map{ |f| f**2 }.inject(&:+))
          l <= 0.5
        }.all?

      _f = 1/3 * @simplex.map(&:result).inject(&:+)
      _d = 1/3 * @simplex.map{ |e| (e.result - _f)**2 }.inject(&:+)
      _d <= TOLERANCE**2
    end

    def func parameter_set
      unless @results.has_key? parameter_set.key
        values = Hash.new { |h, k| h[k] = [] }
        # n-fold cross validation
        @folds.each.with_index do |fold,index|
          # start async SVM training  | ( trainings_set, parameter, validation_sets)
          model, result, _ = @worker.train( fold, parameter_set,
                                                 @folds.select.with_index{|e,ii| index!=ii } )
          next if model.nil?
          values[parameter_set.key] << result
        end
        # calculate means for each parameter pair
        values = values.map{|k,v| {k => v.instance_eval { reduce(:+) / size.to_f }}}
        # flatten array of hashed into one hash
        @results.merge! Hash[*values.map(&:to_a).flatten]
      end
      @results[parameter_set.key]
    end
  end
end
