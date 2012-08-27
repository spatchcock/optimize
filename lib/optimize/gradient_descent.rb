module Optimize

  class GradientDescent < Strategy

    # This class represents the Gradient Descent strategy, whereby new candidate
    # solutions are chosen based on the local rate of change of the cost function
    # and an arbitrary step size.

    # Solutions are dependent on the initial guesses and the chosen step size.

    # Initial guesses are currently randomly chosen although the bounds of this
    # guess is determined by the @search_space hash variable. Initial guesses
    # determine which local minima within in the global function is found.

    # Large step sizes can cause oscillation or more erratic behaviour if not small
    # enough to enable smooth convergence to a solution. Oscilliations may still
    # converge to a solution, but may take a greater number of iterations since the
    # net increment on each cycle is smaller. In some cases (e.g. exponential 
    # functions) the transition from positive to negative candidate parameter values
    # may also cause instability. This may be mitigated by choosing a smaller step size
    # so as to reduce the probability of the respective parameter edging towards zero.

    attr_accessor :step_size, :precision

    def initialize(options={})
      super

      # The step size, often called the 'learning_rate' and denoted by gamma (γ)
      @step_size = 0.0001 
      # Precision - determines when a solution is acceptable
      @precision = 0.001
      @candidate_vector = Proc.new { |last,previous| downslope_vector(last,previous) }
    end

    def search
      error = @precision

      previous_candidate, last_candidate, candidate = nil

      until error < @precision do

        previous_candidate = last_candidate || bootstrap_candidate
        last_candidate     = candidate      || bootstrap_candidate

        candidate = {}
        candidate[:vector] = @candidate_vector.call(last_candidate,previous_candidate)
        candidate[:cost]   = objective_function(candidate[:vector])

        # Catch any errors associated with large step sizes
        # Perhaps this should be handled with a restart?
        break if candidate[:cost].nan? || candidate[:cost].infinite?

        # Error defined as difference between cost estimates with a separation of
        # two iterations. This helps to avoid any problems with oscillating solutions.
        error = (candidate[:cost] - previous_candidate[:cost]).abs

        puts " > cost: #{candidate[:cost]}\tvector: #{candidate[:vector].inspect}"
      end

      puts "\nDone. Best Solution: cost, #{candidate[:cost]}, vector, #{candidate[:vector].inspect}"

      return candidate
    end

    protected

    def bootstrap_candidate
      {}.tap do |hash|
        hash[:vector] = random_vector
        hash[:cost]   = objective_function(hash[:vector])
      end
    end

    def downslope_vector(last,previous)

      vector = @search_space.map do |param,space|

        # Calculate the partial derivative of each parameter, i.e. the rate of
        # change of the cost function per unit change in parameter WITH ALL OTHER
        # PARAMETERS HELD CONSTANT.
        #
        # Use the previous vector (i.e. oldest values for all other paramters) with
        # the last value for the parameter under consideration.

        partial_vector = previous[:vector].merge({param => last[:vector][param]})
        partial_cost   = objective_function(partial_vector)

        # Calculate the change in parameter - often known as epsilon (ε)
        # Calculate the change in cost attributable to parameter in isolation.
        delta_param = last[:vector][param] - previous[:vector][param]
        delta_cost  = partial_cost - previous[:cost]

        # Rate of change of cost with respect to parameter in isolation
        partial_derivative = delta_cost / delta_param

        # Increment last used value for parameter on the basis of the local rate of
        # change and the chosen step size
        [param, last[:vector][param] - @step_size * partial_derivative]
      end

      Hash[vector] 
    end

  end

end