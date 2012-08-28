require 'optimize'

include Math

describe Optimize::GradientDescent do


	it "should find a solution for linear gradient using explicitly define candidate vector" do
		function = Math.function { 10 * x + 2 }

		solver = Optimize::GradientDescent.new
		solver.search_space[:x] = 10
		solver.objective_function = Proc.new { |vector| function.absolute_difference(32.0, vector) }

		solver.search[:vector][:x].should be_within(0.1).of(3)
	end

	it "should find a solution for exponential function using search space specification" do
		function = Math.function { 10.0 * Math.exp(1.0 * x) }

		solver = Optimize::GradientDescent.new
		solver.search_space[:x] = 10

		solver.step_size = 0.000001

		solver.objective_function = Proc.new { |vector| function.absolute_difference(4000.0, vector) }

		solver.search[:vector][:x].should be_within(1.0).of(6.0)
	end

	context "least squares" do

		it "should find a solution to simple least square problem" do
			function = Math.function(:variable => :x) { a * x }
			data     = Distribution.new([1,2,3,4, 5, 6, 7, 8, 9,10],
                                  [1,4,7,8,10,12,14,17,18,20])

			solver = Optimize::GradientDescent.new
		  solver.search_space[:a] = 10

			solver.objective_function = Proc.new do |vector|
				candidate = function.set(vector).distribution(data.x)
				candidate.sum_of_squares(data)
			end

			solver.search[:vector][:a].should be_within(0.1).of(2.0)
		end

		it "should find a solution to simple least square problem with intercept" do
			function = Math.function(:variable => :x) { a * x + c }
			data     = Distribution.new([1,2, 3, 4, 5, 6, 7, 8, 9,10],
				                          [6,9,12,13,15,17,19,22,23,25])

			solver = Optimize::GradientDescent.new
		  solver.search_space[:a] = 100
		  solver.search_space[:c] = 10

		  solver.step_size = 0.001

			solver.objective_function = Proc.new do |vector|
				candidate = function.set(vector).distribution(data.x)
				candidate.sum_of_squares(data)
			end

			solution = solver.search[:vector]
			solution[:a].should be_within(1.0).of(2.0)
			solution[:c].should be_within(3.0).of(5.0)
		end

		it "should find a solution to exponential least square problem" do
			function = Math.function(:variable => :x) { a * Math.exp(-b * x) }
			data     = Distribution.new([ 0, 5,10,15,20,25,30,35,40,45,50],
				                          [61,39,22,12, 9, 5, 2, 2, 2, 1, 1])

			solver = Optimize::GradientDescent.new
		  solver.search_space[:a] = 100
		  solver.search_space[:b] = 1

		  solver.step_size = 0.000002

			solver.objective_function = Proc.new do |vector|
				candidate = function.set(vector).distribution(data.x)
				candidate.sum_of_squares(data)
			end

			solution = solver.search[:vector]
			solution[:a].should be_within(10.0).of(61.0)
			solution[:b].should be_within(0.1).of(0.1)
		end


	end

end