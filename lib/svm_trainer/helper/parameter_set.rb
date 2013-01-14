module Trainer
  #
  # ParameterSet for the NelderMead
  #
  # @author Andreas Eger
  #
  class ParameterSet
    include Comparable
    attr_accessor :gamma, :cost
    attr_accessor :result
    def initialize(gamma, cost)
      @gamma = gamma
      @cost = cost
    end
    def +(other)
      self.class.new(self.gamma + other.gamma, self.cost + other.cost)
    end
    def -(other)
      self.class.new(self.gamma - other.gamma, self.cost - other.cost)
    end
    def *(other)
      case other
      when ParameterSet
        self.class.new(self.gamma * other.gamma, self.cost * other.cost)
      else
        self.class.new(self.gamma * other, self.cost * other)
      end
    end
    def /(other)
      case other
      when ParameterSet
        self.class.new(self.gamma / other.gamma, self.cost / other.cost)
      else
        self.class.new(self.gamma / other, self.cost / other)
      end
    end
    def to_a
      [gamma, cost]
    end
    def <=>(other)
      self.result <=> other.result
    end
    def key
      {gamma: gamma, cost: cost}
    end
  end
end