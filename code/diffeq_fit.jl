
using Distributions
using Turing
using DifferentialEquations

function lotka_volterra(du,u,p,t)
    x, y = u
    α, β, γ, δ  = p
    du[1] = (α - β*y)x # dx =
    du[2] = (δ*x - γ)y # dy =
end

p = [1.5, 1.0, 3.0, 1.0]
u0 = [1.0,1.0]
prob1 = ODEProblem(lotka_volterra,u0,(0.0,10.0),p)
sol = solve(prob1,Tsit5())
plot(sol, linewidth=4, xlabel="Time", ylabel="Population size")

sol1 = solve(prob1,Tsit5(),saveat=0.5)
odedata = Array(sol1) + 0.8 * randn(size(Array(sol1)))
plot(sol1, alpha=0.3, legend = false, linewidth=4,
        xlabel="Time", ylabel="Population size");
scatter!(sol1.t, odedata')

prob = remake(prob1, p=p)
predicted = solve(prob,Tsit5(),saveat=0.1)

@model function fitlv(data, prob1)
    σ ~ InverseGamma(2, 3) # ~ is the tilde character
    α ~ truncated(Normal(1.5,0.5),0.5,2.5)
    β ~ truncated(Normal(1.2,0.5),0,2)
    γ ~ truncated(Normal(3.0,0.5),1,4)
    δ ~ truncated(Normal(1.0,0.5),0,2)

    p = [α,β,γ,δ]
    prob = remake(prob1, p=p)
    predicted = solve(prob,Tsit5(),saveat=1)

    for i = 1:length(predicted)
        data[:,i] ~ MvNormal(predicted[i], σ)
    end
end

model = fitlv(odedata, prob1)

# This next command runs 3 independent chains without using multithreading.
chain = mapreduce(c -> sample(model, NUTS(.65),1000), chainscat, 1:3)

plot(chain)


pl = scatter(sol1.t, odedata');
chain_array = Array(chain)
for k in 1:300
    resol = solve(remake(prob1,p=chain_array[rand(1:1500), 1:4]),Tsit5(),saveat=0.1)
    plot!(resol, alpha=0.1, color = "#BBBBBB", legend = false)
end
plot!(sol1, w=1, legend = false)




function hsc_fates(du, u, θ, t)
    hsc, st, mpp, cmp, clp = u
    (λhsc, λst, λmpp,
        αst, αmpp, αcmp, αclp) = θ
    du[1] = λhsc*hsc - αst*hsc
    du[2] = αst*hsc + λst*st - αmpp*st
    du[3] = αmpp*st + λmpp*mpp - αcmp*mpp - αclp*mpp
    du[4] = αcmp*mpp
    du[5] = αclp*mpp
end

θ = [1/110, 1/24, 4, 1/110, 1/22, 4, 1/46]
u0 = [1.0, 0.0, 0.0, 0.0, 0.0]
prob = ODEProblem(hsc_fates, u0, (0.0, 300.0), θ)
sol = solve(prob, saveat=1)
plot(sol, linewidth=4, yaxis=:log10, ylim=(0.1, 1000),
        xlabel="Time (days)", ylabel="Cells")
plot(sol[:, 1])

[u[2] for (u,t) in tuples(sol)]
