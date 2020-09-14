
### Performance example
### Gillespie algorithm for simple division process

using Distributions
using BenchmarkTools

# division rate
const λ = 2.0

# initial cell number
const x0 = 1

# time range to simulate
const Δt = 3.0

# number of simulation repeats
const n = 10000

function gillespie_alg(x0, λ, Δt, n)
    # preallocate result array
    res = zeros(Int, n)

    for i=1:n
        # current cell numbers and current time
        x = x0
        t = 0.0

        # simulate
        while t < Δt
            # calculate propensity
            prop = x * λ

            # draw exponential random time for next event
            τ = rand(Exponential(1.0/prop))

            # update current cell numbers and time
            x += 1
            t += τ

        # store single simulation result
        res[i] = x
        end
    end
    # return result
    res
end

const res = gillespie_alg(x0, λ, Δt, n)

# expected mean cell numbers
# dx/dt = λ x  =>  x(t) = x0⋅exp(λ⋅t)
const mean_sol = x0 * exp(λ * Δt)

# mean by Gillespie simulations
const mean_res = mean(res)

@btime gillespie_alg(x0, λ, Δt, n)
@code_warntype gillespie_alg(x0, λ, Δt, n)



### runtime python vs. julia
8.5 / 0.04

### additional profiling
using ProfileView
const n = 1000000
@profview gillespie_alg(x0, λ, Δt, n)
