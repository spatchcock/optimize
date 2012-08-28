module Optimize

  module Random

    def random_candidate
      {}.tap do |hash|
        hash[:vector] = random_vector
        hash[:cost]   = objective_function(hash[:vector])
      end
    end

    protected

    def random_vector
      vector = @search_space.map do |variable, search_space| 
        [variable, random_param(search_space)]
      end

      Hash[vector] 
    end

    def random_param(search_space)
      return rand * search_space                                             if search_space.is_a? Fixnum 
      return search_space.min + rand * (search_space.max - search_space.min) if search_space.is_a? Range
      # handle probability density function                                  if search_space.is_a? Distribution
      # handle probability density function                                  if search_space.is_a? Function
    end

  end

end