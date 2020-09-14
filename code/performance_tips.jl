
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











### OLD NOTES BELOW
### exercise 01 (type )
# compute this sum: (1/1)^2 + (1/2)^2 + (1/3)^2 + ... + (1/1000)^2
# (exact result for infinite sum is π^2/6)
π^2/6

@btime
function addup()
    sum((1 ./vals).^2)
end
@btime addup() # 780.369 ns

function addup()
    res = 0
    for i=1:1000
        res += (1/i)^2
    end
    res
end
@btime addup() # 1.230 μs
@code_warntype addup()

function addup()
    res = 0.0
    for i=1:1000
        res += (1.0/i)*(1.0/i)
    end
    res
end
@btime addup() # 1.230 μs
@code_warntype addup()

### exercise 02 (devectorise/fuse broadcasting/in-place)
# compute sin(x)^2 + cos(x)^2 for x = [1, 2, 3, ..., 100]
function trig!(x)
    x .= sin.(x).^2 .+ cos.(x).^2
    x
end
const x = Float64[i for i=1:100]
trig!(x)
@btime trig!(x)
@btime trig($x)
@btime trig(Float64[i for i=1:100])
@btime trig($Float64[i for i=1:100])

y = Float64[i for i=1:100]
@btime trig(y)
@btime trig($y)

function trig!(x)
    for i in 1:length(x)
        x[i] = sin(x[i])^2 + cos(x[i])^2
    end
    x
end
@btime trig!(x)

# create copy/not in-place (a bit slower and more allocations)
function trig(x)
    y = similar(x)
    for i in 1:length(x)
        y[i] = sin(x[i])^2 + cos(x[i])^2
    end
    y
end
@btime trig(x)

# non-fusing broadcasting
function trig(x)
        y = sin.(x).^2 + cos.(x).^2
end
@btime trig(x)

z = Float64[1, 2, 3]
w = Float64[4, 5, 6]
@btime exp.(abs.(z - w))
@btime exp.(abs.(z .- w))

function expabs(x, y)
    z = similar(x)
    for i in 1:length(x)
        z[i] = exp(abs(x[i]-y[i]))
    end
end
@btime expabs(z, w)

function expabs(x, y)
    z = similar(x)
    z .= exp.(abs.(x-y))
end
@btime expabs(z, w)

function expabs(x, y)
    z = similar(x)
    z .= exp.(abs.(x.-y))
end
@btime expabs(z, w)

function expabs(x, y)
    z = exp.(abs.(x.-y))
end
@btime expabs(z, w)
