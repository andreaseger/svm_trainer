module SvmTrainer
  #
  # ParameterSet for the NelderMead
  #
  # @author Andreas Eger
  #
  class ParameterSet
    include Comparable
    include Libsvm
    CACHESIZE = (ENV['SVM_CACHESIZE'] || 64).to_f
    attr_accessor :gamma, :cost, :kernel
    attr_accessor :result
    def self.from_key(key)
      new(key[:gamma], key[:cost], key[:kernel])
    end
    def initialize(gamma, cost, kernel=:rbf)
      @result = 0.5 #this equals a random selection
      @gamma = gamma
      @cost = cost
      @kernel = kernel
      @probability = false
    end
    def self.real(gamma, cost, kernel=:rbf)
      new(Math.log2(gamma), Math.log2(cost), kernel)
    end
    def key
      {gamma: gamma, cost: cost, kernel: kernel}
    end
    def key2
      {gamma: 2**gamma, cost: 2**cost, kernel: kernel}
    end
    def to_parameter
      kernel_type =  case self.kernel
                      when :linear
                        KernelType::LINEAR
                      when :rbf
                        KernelType::RBF
                      else
                        KernelType::RBF
                      end

      SvmParameter.new(svm_type: SvmType::C_SVC,
                      kernel_type: kernel_type,
                      cost: 2**self.cost,
                      gamma: 2**self.gamma,
                      probability: (self.probability? ? 1 : 0),
                      cache_size: CACHESIZE)
    end
    def to_a
      [gamma, cost]
    end
    def to_s
      "gamma: #{gamma} | cost: #{cost} | kernel: #{kernel}"
    end
    def probability?
      @probability
    end
    def enable_probability!
      @probability = true
    end
    def disable_probability!
      @probability = false
    end

    #
    # Comparable Mixin
    def <=>(other)
      self.result <=> other.result
    end

    # looks a little bit of messy but can't be done with define_method
    # only alternative would be to write this method 4 times
    %w(+ - * /).each do |op|
      eval <<-END_RUBY
        def #{op}(other)
          case other
          when ParameterSet
            self.class.new(self.gamma.to_f #{op} other.gamma, self.cost.to_f #{op} other.cost, self.kernel)
          else
            self.class.new(self.gamma.to_f #{op} other, self.cost.to_f #{op} other, self.kernel)
          end
        end
      END_RUBY
    end
    #
    # enables calculations with numbers without having to care about order
    def coerce(other)
      if other.is_a? ParameterSet
        [self, other]
      else
        [ParameterSet.new(other, other, self.kernel), self]
      end
    end
  end
end
