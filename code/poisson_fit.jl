
using Random
using Distributions
using Turing
using Plots
using StatsPlots
using JLD
# using AdvancedPS

# make fonts a bit larger generally
Plots.scalefontsizes(1.5)

### load data
data_poisson = load("data_poisson.jld")
data = data_poisson["data5"]
histogram(data, bins=range(-0.5, 24.5, step=1),
            normalize=true, label="Data", xlabel="mRNA numbers",
            ylabel="Probability density", linecolor=:match)

### inference based on Turing (conjugate prior)
### (uses automatic differentiation)
# setting up Turing model
λprior = 8
plot(range(0, stop=20, length=1000), linewidth=4,
            Gamma(λprior, 1), xlabel="λ", ylabel="Probability",
            label="p(λ)", color=:darkorange)

@model function poisson_fit(data, λprior)
    λ ~ Gamma(λprior, 1)

    for i in 1:length(data)
        data[i] ~ Poisson(λ)
    end
end
poisson_fit(data) = poisson_fit(data, λprior)

# sampling
iterations = 1000
ϵ = 0.05
τ = 10
chain = sample(poisson_fit(data), HMC(ϵ, τ), iterations)

# plotting
plot(chain[:λ], label="λ|D samples", linecolor=:tomato,
        xlabel="MCMC Iterations", ylabel="λ",
        legend=:best)
p = histogram(chain[:λ].data[100:end], color=:tomato,
                normalize=true, label="p(λ | D) [Posterior]",
                linecolor=:match, xlabel="λ", ylabel="Probability");
p = plot!(range(0, stop=15, length=1000), linewidth=4,
                Gamma(λprior, 1),
                label="p(λ) [Prior]", color=:darkorange);
p = plot!(range(0, stop=15, length=1000), linewidth=4,
                Gamma(λprior + sum(data), 1/(length(data)+1)),
                label="p(λ | D) [Analytical]", color=:red,
                legend=:topleft)

### Turing uniform solution below ⬇

















### inference based on Turing (uniform prior)
# setting up Turing model
plot(range(0, stop=20, length=1000), linewidth=4,
            Uniform(5, 15), ylim=(0, 1),
            xlabel="λ", ylabel="Probability",
            label="p(λ)", color=:darkorange)

@model function poisson_fit(data)
    λ ~ Uniform(5, 15)

    for i in 1:length(data)
        data[i] ~ Poisson(λ)
    end
end

# sampling
iterations = 1000
ϵ = 0.05
τ = 10
chain = sample(poisson_fit(data), HMC(ϵ, τ), iterations)

# plotting
plot(chain[:λ], label="λ|D samples", linecolor=:tomato,
        xlabel="MCMC Iterations", ylabel="λ",
        legend=:best)
p = histogram(chain[:λ].data[100:end], color=:tomato,
                normalize=true, label="p(λ | D) [Posterior]",
                linecolor=:match, xlabel="λ", ylabel="Probability");
p = plot!(range(0, stop=20, length=1000), linewidth=4,
                Uniform(5, 15), label="p(λ) [Prior]",
                color=:darkorange, legend=:topleft)

### create some data
# create Poisson data with given mean
# fix random seed
# Random.seed!(15092020)
# datan = 50
# λtrue = 10
# data = rand(Poisson(λtrue), datan)
# save("data_poisson.jld", "data50", data, "data5", data5)

### inference based on manual setup
### (need AdvancedPS install)
# priors = (
#     λ=(Gamma(λtrue, 1),),
# )
#
# bounds = ((0.0, Inf),)
#
# function loglike(λ, data)
#     return sum(logpdf.(Poisson(λ), data))
# end
#
# loglike(θ) = loglike(θ..., data)
#
# model = DEModel(priors=priors, model=loglike)
#
# de = DE(bounds=bounds, burnin=500, priors=priors, progress=true)
# n_iter = 1000
# chains_exact = psample(model, de, n_iter)
#
# # chains of parameters (after burn in)
# p = plot(chains_exact.value[:, "λ", :].data, label=false,
#         xlabel="Iterations (DEMCMC)", ylabel="Parameter λ");
# display(p)
#
# # p = histogram(chains_exact.value[:, "λ", :].data);
# # display(p)
#
# M_all = vcat(chains_exact.value[:, ["λ"], :]...)
# p = histogram(M_all, bins=30, normalized=true, label="Exact DEMCMC",
#         fillcolor=:dodgerblue, xlabel="Posterior p(λ | Data)", ylabel="Probability density");
# p = plot!(range(8.5, 12, step=0.01), pdf.(Gamma(λtrue + sum(data), 1/(datan+1)), range(8.5, 12, step=0.01)),
#         width=2.5, label="Analytical", color=:darkorange);
# display(p)
#
# p = plot(M_all, label=false, #alpha=0.5,
#     grid=false, xlabel="Iterations (DEMCMC)", ylabel="Parameter value (λ)");
# display(p)
