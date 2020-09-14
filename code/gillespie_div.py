
import numpy as np
import time

# division rate
λ = 2.0

# initial cell number
x0 = 1

# time range to simulate
Δt = 3.0

# number of simulation repeats
n = 10000

def gillespie_alg(x0, λ, Δt, n):
    # preallocate result array
    res = np.zeros(n)

    for i in range(n):
        # current cell numbers and current time
        x = x0
        t = 0.0

        # simulate
        while t < Δt:
            # calculate propensity
            prop = x * λ

            # draw exponential random time for next event
            τ = np.random.exponential(1.0/prop)

            # update current cell numbers and time
            x += 1
            t += τ

        # store single simulation result
        res[i] = x
    # return result
    return res

start = time.time()
res = gillespie_alg(x0, λ, Δt, n)
end = time.time()
print(f"Run time = {end-start} s")

# expected mean cell numbers
# dx/dt = λ x  =>  x(t) = x0⋅exp(λ⋅t)
mean_sol = x0 * np.exp(λ * Δt)
print(mean_sol)

# mean by Gillespie simulations
mean_res = np.mean(res)
print(mean_res)

print(type(res))
print(res)
