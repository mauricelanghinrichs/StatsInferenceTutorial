
using BenchmarkTools

### exercise 01
function mult3_v1!(x)
		x .= 3 .* x
end
@btime mult3_v1!(x) setup=(x = [i for i in 1:100000]) evals=1

function mult3_v2!(x)
	x = 3 * x
end
@btime mult3_v2!(x) setup=(x = [i for i in 1:100000]) evals=1

function mult3_v3!(x)
	@inbounds for i=1:length(x)
		x[i] = 3 * x[i]
	end
	x
end
@btime mult3_v3!(x) setup=(x = [i for i in 1:100000]) evals=1

### exercise 02
function mult3_v1!(x)
		x .= 3 .* x
		x
end
@btime mult3_v1!(x) setup=(x = [i for i in 1:100000]) evals=1

function mult3_v1(x)
	y = zeros(Int, length(x))
	y .= 3 .* x
	y
end
@btime mult3_v1(x) setup=(x = [i for i in 1:100000]) evals=1

### exercise 03
function divide_v1()
	x=1
	for i in 1:10
		x = x/2
	end
	x
end

function divide_v2()
	x=1.0
	for i in 1:10
		x = x/2
	end
	x
end
@btime divide_v1()
@btime divide_v2()
@code_warntype divide_v1()
@code_warntype divide_v2()
