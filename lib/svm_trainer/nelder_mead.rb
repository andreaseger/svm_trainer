require_relative 'base'
require_relative 'helper/parameter_set'
module Trainer
  #
  # Trainer for a parmeter search using the Nelder-Mead Simplex heurisitc with the RBF kernel
  #
  # @author Andreas Eger
  #
  class NelderMead < Base
    # default number of iterations to use during parameter search
    DEFAULT_MAX_ITERATIONS=3
    def name
      "Nelder-Mead Simplex Heuristic with #{number_of_folds}-fold cross validation"
    end
    def label
      "nelder_mead"
    end

    def initialize args
      super
      @simplex = []
      @func = {}
    end

    #
    # perform a search on the provided feature vectors
    # @param  feature_vectors
    #
    # @return [model, results] trained svm model and the results of the search
    def search feature_vectors, max_iterations=DEFAULT_MAX_ITERATIONS
      # split feature_vectors into folds
      @folds = make_folds feature_vectors

      # create Celluloid Threadpool
      @worker = Worker.pool(args: [{evaluator: @evaluator}] )

      initial_simplex
      loop do
        best, worse, worst = order
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
      best_parameter = @func.invert[@func.values.max]

      binding.pry
      model = train_svm feature_vectors, params = {cost: 2**best_parameter[:cost], gamma: 2**best_parameter[:gamma]}
      return model, results
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
      p 'iteration'
      return false unless @simplex.permutation(2).map { |e|
          l = Math.sqrt((e[0] - e[1]).to_a.map{ |f| f**2 }.inject(&:+))
          l <= 0.5
        }.all?

      _f = 1/3 * @simplex.map(&:result).inject(&:+)
      _d = 1/3 * @simplex.map{ |e| (e.result - _f)**2 }.inject(&:+)
      _d <= TOLERANCE**2
    end

    #TODO fix this parameter mess, either use the real(**2) ones everywhere or the other way around
    def func parameter_set
      unless @func.has_key? parameter_set.key
        futures=[]
        # n-fold cross validation
        params = {cost: 2**parameter_set.cost, gamma: 2**parameter_set.gamma}
        @folds.each.with_index do |fold,index|
          # start async SVM training  | ( trainings_set, parameter, validation_sets)
          futures << @worker.future.train( fold, params,
                                           @folds.select.with_index{|e,ii| index!=ii } )
        end
        # collect results - !blocking!
        # and add result to cache
        @func[parameter_set.key] = collect_results(futures)[params]
      end
      @func[parameter_set.key]
    end
  end
end