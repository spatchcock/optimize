module Optimize

  class Strategy

    attr_reader :search_space

    def initialize(options={})
      @search_space = {}
      @objective_function = nil
      @candidate_vector   = nil
    end

    def objective_function(candidate_vector)
      @objective_function.call(candidate_vector)
    end

    def objective_function=(block)
      @objective_function = block
    end

    def candidate_vector
      @candidate_vector.call
    end

    def candidate_vector=(block)
      @candidate_vector = block
    end

  end

end