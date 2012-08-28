module Optimize

  class RandomSearch < Strategy

    include Random

    def initialize(options={})
      super
      @candidate_vector = Proc.new { random_vector }
    end

    def default_iterations
      @default_iterations || 1000
    end

    def default_iterations=(number)
      @default_iterations = number
    end

    def search(iterations=nil)
      best = nil
      (iterations || default_iterations).times do |iter|

        candidate = random_candidate
        best      = candidate if best.nil? or candidate[:cost] < best[:cost]

        puts " > iteration: #{(iter+1)}\tbest: #{best[:cost]}\tvector: #{best[:vector]}"
      end

      puts "\nDone. Best Solution: cost: #{best[:cost]}, vector: #{best[:vector].inspect}"
      return best
    end

  end

end