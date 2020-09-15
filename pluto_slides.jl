### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 350c6846-f52e-11ea-2c8e-69d7aaadebbe
html"<button onclick=present()>Presentation mode</button>"

# ╔═╡ ba641ca0-f678-11ea-2517-4f85ea4d3423
begin
	# we set up a clean package environment
	# (here and in the next cell)
	import Pkg
	Pkg.activate(mktempdir())
end

# ╔═╡ 3d9f3eec-f665-11ea-2b71-678afc915989
begin
	# import packages
	# (if packages are already installed, the globally
	# installed version will be used automatically)
	Pkg.add("Distributions"); using Distributions
	Pkg.add("Turing"); using Turing
	Pkg.add("DifferentialEquations"); using DifferentialEquations
	Pkg.add("JLD"); using JLD
	Pkg.add("Pluto"); using Pluto
	Pkg.add("PlutoUI"); using PlutoUI
	Pkg.add("Plots"); using Plots
	Pkg.add("StatsPlots"); using StatsPlots
	Pkg.add("BenchmarkTools"); using BenchmarkTools
end

# ╔═╡ f3c20672-f51c-11ea-3303-cd9b65133594
md""" # _Statistical inference with Julia_

###### Group Retreat Heidelberg, Matthias and Maurice, 15. September 2020
\
$(PlutoUI.LocalResource("images/julialogo.png", :width => 100))
"""

# ╔═╡ 2d1f4f7a-f52b-11ea-0c75-cd873132c58d
begin
	λintro = 10
	poi_slider = @bind λintro html"<input type='range' min='1' max='20' step='1' value='10'>"

	md"Poisson parameter: $(poi_slider)"
end

# ╔═╡ b2b071e6-f6a4-11ea-2962-593a281afa51
begin
	intro_data = rand(Poisson(λintro), 20)
	histogram(intro_data,
		bins=range(-0.5, 24.5, step=1), normalize=true,
		color=:dodgerblue, linecolor=:match, label="Data")
	plot!(Poisson(mean(intro_data)), grid=false, label="Poisson fit",
			xlabel="mRNA numbers", ylabel="Probability",
			linewidth=4, color=:darkorange, markerstrokewidth=0,
			xlim=(0, 30), ylim=(0, 0.3))
	plot!(size=(350,200))
end

# ╔═╡ debd8066-f52e-11ea-03d7-55093d4d50ff
md"""
(Package imports above title)
"""

# ╔═╡ b60cf1a8-f525-11ea-1476-4787760c3654
md"""
## Before we start

_Tutorial requirements_ (the complete process should take <30 min.)
1. [Julia installation](https://julialang.org/downloads/)
2. Optional: [Atom and Juno (the Julia editor)](http://docs.junolab.org/latest/man/installation/)
3. Julia packages listed below:
"""

# ╔═╡ fd8a6856-f5bd-11ea-0394-655187f55a4a
Text(sprint(io -> Pkg.status(io=io)))

# ╔═╡ de89e6ba-f5be-11ea-35e1-1dbfda29ca4a
md"""
_How to install and precompile Julia packages_
1. Start Julia in the terminal (Applications -> Julia-1.5)
2. Enter “]” to get into Julia package mode (pkg>)
3. Install a package X by writing “add X” (e.g., "add Plots", repeat for each package)
4. View all installed packages with “status”
5. Precompile all packages with “precompile”
6. Leave the package mode by pressing backspace (julia>)
7. (General info: Import a package by “using X” for a package X)

_How to start this Pluto notebook_

1. Start Julia in the terminal (Applications -> Julia-1.5)
2. Import Pluto by typing "using Pluto"
3. Open Pluto in a browser by typing "Pluto.run(1234)"
4. Open this notebook file via the Pluto user interface

(Currently, Pluto is supposed to work best with Firefox or Chrome)
"""

# ╔═╡ 38bcd576-f69f-11ea-04b6-5b497457c85a
md"""
## Content of this Tutorial
1) **Introduction to Julia**
2) **Performance tips and a Gillespie algorithm**
3) **Differential Equations in Julia**
4) **Bayesian Inference and Probabilistic Programming**
5) **_Everything from above, just combined :)_**
6) **Further Information/References**
"""

# ╔═╡ 37109e76-f5c1-11ea-196d-99c2ac49a062
md"## 1. Introduction: What is Julia?

_Goal_: Write code as in Matlab/Python/R which is as fast as C/C++/Fortran

_Basic language principles_
- Multi-platform via LLVM
- Multi-paradigm (functional, object-oriented, ...)
- Multiple dispatch
- Dynamic with type inference
- Just-in-time (JIT) compilation
- Broad metaprogramming features
- Open source
"

# ╔═╡ aa95fe4e-f5c2-11ea-08e3-715fd74b8947
md"""## The Two Language Problem

_Effort and language barriers_
- prototype code with a language that is _fast to code with_ (Python, R, Matlab)
- tranfer the prototype code to a language that _runs fast_ (C, C++, Fortran)
\
The numpy package in Python (basic array class for fast computing)

$(PlutoUI.LocalResource("images/two_lang_numpy.png", :width => 300))
\
\
A typical Julia package (Turing.jl)

$(PlutoUI.LocalResource("images/two_lang_turing.png", :width => 300))
\

_Julia solves the two language problem_
- you can prototype code in Julia
- you can improve code performance in the same language
- no language barrier

"""

# ╔═╡ 7575f402-f5d0-11ea-05f4-75eb4096930d
md"## Basic syntax

###### Getting help

Precede unknown object/expression with a question mark (`?`) to see the docs (Pluto has Live docs for this)"

# ╔═╡ fb7d2fc8-f6b5-11ea-2d3d-c566c4292a4c
md"###### Some basic data structures

1. _Tuples_ (ordered, immutable)
2. _Named Tuples_ (ordered, immutable)
3. _Arrays_ (ordered, mutable)
4. _Dictonaries_ (unordered, mutable)

_Tuples_ and _Named Tuples_ are constructed using paratheses"

# ╔═╡ 065885ca-f6b4-11ea-39ee-bbca217e81d7
myTuple = (3, 1, 4);

# ╔═╡ 0766c508-f6b4-11ea-2776-d100ed8c4b7e
myNamedTuple = (foo = 1, bar = 5, baz = 9);

# ╔═╡ 1c0dde9c-f6b4-11ea-38d9-af2e85e6dad9
md"Elements are accessed by position (**In Julia indexing starts at 1!**)"

# ╔═╡ 2341a2b6-f6b4-11ea-3946-97e162f449ce
myTuple[2];

# ╔═╡ 280b5d30-f6b4-11ea-32bf-4dd537092235
myNamedTuple[3];

# ╔═╡ 5fd479ec-f6b4-11ea-199f-630771b2dac3
md"_Named Tuples_ can additionally be accessed by name"

# ╔═╡ 63bad2e0-f6b4-11ea-24dc-c93e9fec1259
myNamedTuple[:baz];

# ╔═╡ 6ef88076-f6b4-11ea-2625-91fa654744e4
md"To form collections of related values, use _Dictionaries_ or _Arrays_"

# ╔═╡ 79f18f18-f6b4-11ea-2833-b1bf5cf2adb6
myArray = [2, 6, 5];

# ╔═╡ 7dd62f6c-f6b4-11ea-391f-df2994da3551
myDict = Dict("foo" => 3, "bar" => 5, "baz" => 8);

# ╔═╡ d8bca430-f6b5-11ea-085d-839f76472e31
md"_Arrays_ are accessed by indexing"

# ╔═╡ db5c71e0-f6b5-11ea-2259-01d0e71302d6
myArray[1];

# ╔═╡ dee751ae-f6b5-11ea-332d-f7fd57b88a3d
md"_Dictionaries_ are (unordered) collections of (key, value)-pairs, values are retrieved via corresponding key"

# ╔═╡ e6d2f22e-f6b5-11ea-1d89-dda69d6b459c
myDict["foo"];

# ╔═╡ fb7f685a-f5d0-11ea-13f5-ed782705b7c7
md"###### Loops and control-flow"

# ╔═╡ c89da684-f6b5-11ea-2fa1-43ecc44703f3
my_arr1 = [4, 5, 6];

# ╔═╡ edf4ea28-f5d2-11ea-02d4-43772be1576a
my_arr2 = zeros(length(my_arr1));

# ╔═╡ 6f18bc2a-f5d2-11ea-12c3-875a26c75ef6
for i in 1:length(my_arr1)
	my_arr2[i] = 2*my_arr1[i]
end

# ╔═╡ da13abe8-f5d2-11ea-1614-afd878920560
my_arr2;

# ╔═╡ 0411bfac-f5d3-11ea-2f0f-a5a2bdce4f65
md"###### Functions"

# ╔═╡ 0ed01aec-f5d3-11ea-1ff1-5d2d6e6cad8e
function double_vals(my_arr1)
	my_arr2 = zeros(length(my_arr1))
	for i in 1:length(my_arr1)
		my_arr2[i] = 2*my_arr1[i]
	end
	my_arr2
end;

# ╔═╡ 5a4690a0-f5d3-11ea-1b4e-238ee7fa9f09
double_vals(my_arr2);

# ╔═╡ da64181c-f532-11ea-2276-33baf092559c
md"## Type inference"

# ╔═╡ a94ffb96-f5d3-11ea-2b91-0d12431f2e80
md"Julia is a dynamic language, you don't have to specify types, but you can. Either way, Julia will try to infer types that allow fast subsequent computing."

# ╔═╡ 5dc2ca7c-f539-11ea-2892-8f03b5d76228
some_array = [10, "foo", false]

# ╔═╡ 767fe0f4-f539-11ea-0bda-b9bd8022123a
typeof(some_array)

# ╔═╡ 0a9b4b4a-f533-11ea-0783-8963ceaa253d
[1, 2, 3];

# ╔═╡ 06cde658-f533-11ea-287a-a99d49e6850c
[true, false, true];

# ╔═╡ f4a72ea8-f532-11ea-0eba-0138545cdf04
[1.0, 2.0, 3.0];

# ╔═╡ b0fe25d8-f539-11ea-0cde-3f14645b6c13
md"## Abstract and concrete types"

# ╔═╡ db517cd6-f5cf-11ea-0242-d9a8e320af62
md"_Relationships between types_"

# ╔═╡ ba023b24-f539-11ea-2aee-a1cfc56b550a
Int <: Number;

# ╔═╡ bf5f7276-f539-11ea-0b05-23e37b1397d0
Int <: Float64;

# ╔═╡ bf603706-f539-11ea-28b1-37dcd5886481
Real <: Number;

# ╔═╡ bf613c0a-f539-11ea-1d72-45c9cafdf08c
(Array{T, 1} where T) == (Vector{T} where T);

# ╔═╡ 09b829b2-f5d0-11ea-227d-675f3c591d74
md"_Parents and children of types_"

# ╔═╡ bf690c08-f539-11ea-1cdd-f7f79d127e0d
supertype(Number);

# ╔═╡ bf75ba66-f539-11ea-368a-7bdddb507a95
subtypes(Number);

# ╔═╡ bf89a866-f539-11ea-3292-0f991a288db8
subtypes(Real);

# ╔═╡ bf9003be-f539-11ea-2931-098d4e8a2e8b
subtypes(AbstractFloat);

# ╔═╡ 396a7e4e-f5d0-11ea-3f51-b1243e3dec08
md"_Build your own types_"

# ╔═╡ bfa5ddd6-f539-11ea-0c3b-1fd74faabeb1
abstract type Person end;

# ╔═╡ bfac62ae-f539-11ea-0779-49c930964691
struct Professor<:Person
    students::Vector{String}
end

# ╔═╡ bfb5ce64-f539-11ea-2007-9b250e84943a
Professor <: Person, Person <: Professor;

# ╔═╡ bfca9fa8-f539-11ea-1181-754865c85895
Thomas = Professor(["Matthias", "Maurice"]);

# ╔═╡ bfd4beb4-f539-11ea-3beb-ebd2a9f9f55c
typeof(Thomas);

# ╔═╡ bfe423ae-f539-11ea-1d57-7117ca16fd59
Thomas;

# ╔═╡ 12332104-f53b-11ea-01f7-a783beffc4ee
md"## Multiple Dispatch"

# ╔═╡ 5e03ea98-f5d4-11ea-153b-675bbcb96db8
md"Multiple dispatch is the primary paradigm in Julia; it allows to define the same function for multiple type combinations for the input variables. The most appropriate (i.e. fastest) version is then _dispatched_ to a certain input."

# ╔═╡ aa0ff2c6-f5d4-11ea-384d-a755ddf9c74d
md"_+ is a function in Julia with many different versions (called methods)_"

# ╔═╡ 636f2bd6-f5d5-11ea-3bb2-291598e50a49
+;

# ╔═╡ 5afbaa4a-f73a-11ea-21fb-d97cede4684f
+(2, 3) == 2 + 3;

# ╔═╡ 9c598a9a-f5d5-11ea-39f6-9b979b95c256
@which 1 + 2;

# ╔═╡ a53bb566-f5d5-11ea-13f4-05fb39073a0c
@which 1.0 + 2.0;

# ╔═╡ 05f26410-f5d6-11ea-37c4-f34c9fde0d5d
@which 1.0 + 2;

# ╔═╡ fd514fe6-f5d4-11ea-01cd-97f28ebb6227
md"_Create the function mysum with two different methods_"

# ╔═╡ 22757d6c-f53b-11ea-3eae-7ffd8723a4eb
begin
	function my_sum(arr::Vector{Int})
	  val = 0
	  for i in arr
		val += i
	  end
	  "sum over ints...", val
	end

	function my_sum(arr::Vector{Float64})
	  val = 0.0
	  for i in arr
		val += i
	  end
	  "sum over floats...", val
	end
end;

# ╔═╡ 19d97250-f53b-11ea-05a4-254304584485
my_sum;

# ╔═╡ 4d7b6294-f53b-11ea-0d5e-0d5184dadcb2
my_sum([1, 2, 3, 4]);

# ╔═╡ 4d7d1b52-f53b-11ea-0bc8-4d1082ff0f8e
my_sum([1.0, 2.0, 3.0, 4.0]);

# ╔═╡ 31f8eaa4-f541-11ea-1cde-39e63f4aebea
md"## 2. Performance tips"

# ╔═╡ 9d41be3a-f541-11ea-3b45-6f931e2ad603
md"""
###### For-loops vs. loop-fusion/vectorisation/broadcasting

1) **Exercise**: _Which version is the fastest?_"""

# ╔═╡ adfe85be-f541-11ea-2c9a-d778b46ab90c
begin
	# x is supposed to be an array like
	x = [i for i in 1:10]

	function mult3_v1!(x)
		x .= 3 .* x
	end

	function mult3_v2!(x)
		x = 3 * x
	end

	function mult3_v3!(x)
		@inbounds for i in 1:length(x)
			x[i] = 3 * x[i]
		end
		x
	end
end;

# ╔═╡ 64832bf6-f624-11ea-0f57-3790031bf7a8
mult3_v1!(x);

# ╔═╡ 247df138-f5e8-11ea-310c-79b55d7210b1
md"""
Check box to show solution $(@bind perf_sol_1 html"<input type=checkbox >")
"""

# ╔═╡ 7e228aa2-f541-11ea-1ce8-4bf43de2136f
md"""
###### In-place functions

2) **Exercise**: _What could 'in-place' mean? Which version is in-place and what might be faster?_"""

# ╔═╡ 8a150498-f541-11ea-1374-652ca1454e76
begin
	function inplace_v1!(x)
		x .= 3 .* x
		x
	end

	function inplace_v2(x)
		y = zeros(Int, length(x))
		y .= 3 .* x
		y
	end
end;

# ╔═╡ 0263d3ba-f5ed-11ea-3916-95349ae429d9
md"""
Check box to show solution $(@bind perf_sol_2 html"<input type=checkbox >")
"""

# ╔═╡ af7db644-f541-11ea-3dc7-c928e53b59db
md"""
###### Type-stable code

3) **Exercise**: _What could 'typle-stable' code mean? Which of the following versions has a type-instability? Which is faster?_"""

# ╔═╡ 1869719a-f542-11ea-0186-7bae357a73c5
begin
	function divide_v1()
		x = 1
		for i in 1:10
			x = x/2
		end
		x
	end

	function divide_v2()
		x = 1.0
		for i in 1:10
			x = x/2
		end
		x
	end
end;

# ╔═╡ ca8274e6-f5f2-11ea-293a-4953cd8d69be
md"""
Check box to show solution $(@bind perf_sol_3 html"<input type=checkbox >")
"""

# ╔═╡ 7d4a47d8-f542-11ea-1f7d-53ab0e4ff0a1
md"""More performance tips:
- Use macros and packages to help you find bottlenecks (_not guess about runtime, just test it!_); such as [`@btime`](https://github.com/JuliaCI/BenchmarkTools.jl), `@allocated` and [`@profview`](https://github.com/timholy/ProfileView.jl)
- Use the `@code_warntype` macro to find type-instabilities
- Copying arrays can be expensive, often Views of arrays are enough and much faster!
- Access multi-dimensional arrays along columns since Julia stores in column-major order

More resources:
- [Official performance tips from the Julia Documentation](https://docs.julialang.org/en/v1/manual/performance-tips/)
- [A blog post](https://julialang.org/blog/2013/09/fast-numeric/) (a bit older, but concepts are still true)
"""

# ╔═╡ 3efacc48-f541-11ea-0625-d1212cac1820
md"""## 2. Gillespie algorithm
###### Simple division process, Julia says 'Challenge accepted!'
In the following we have a stochastic simulation algorithm for a simple division process of a single cell with exponential division times (Gillespie algorithm).

_Let's check out how Julia code looks like and how fast it is!_

$(PlutoUI.LocalResource("images/gillespie.png", :width => 800))
"""

# ╔═╡ b1ade5f4-f543-11ea-2a29-1fdc5e7acbcb
begin
	λ = 2.0 # division rate
	x0 = 1 # initial cell number
	Δt = 3.0 # time range to simulate
	n = 10000 # number of simulation repeats

	function gillespie_alg(x0, λ, Δt, n)
		# preallocate result array
		res = zeros(Int, n)

		for i=1:n
			# current cell numbers and current time
			x = x0
			t = 0.0

			# simulate
			while true
				# calculate propensity
				prop = x * λ

				# draw exponential random time for next event
				τ = rand(Exponential(1.0/prop))
				
				# store single simulation result
				if t + τ > Δt
					res[i] = x
					break
				end
				
				# update current cell numbers and time
				x += 1
				t += τ
			end
		end
		# return result
		res
	end
end;

# ╔═╡ 118f1fac-f5f7-11ea-21ec-431225a36961
md"Let's check if we get expected results! We have a linear Gillespie algorithm, thus we know the analytical result for the mean cell numbers as an ordinary differential equation:
$ \frac{\textrm{d}x}{\textrm{d}t} = λ\cdot x \quad \Rightarrow \quad x(t) = x_0⋅\textrm{exp}(λ⋅t) $"

# ╔═╡ 22e5cb2a-f5f7-11ea-3bc2-678184795816
res = gillespie_alg(x0, λ, Δt, n);

# ╔═╡ 59675060-f5f7-11ea-246a-f302300481df
# expected mean
mean_sol = x0 * exp(λ * Δt);

# ╔═╡ 5bb3ac56-f5f7-11ea-3fae-7f83b84cb6da
# mean by Gillespie simulations
mean_res = mean(res);

# ╔═╡ 73888418-f5f8-11ea-2b7c-297e6395e395
begin
	scatter(["Analytical", "Gillespie"], [mean_sol, mean_res],
			ylim=(-10, mean_sol*1.2), xlim=(-0.0, 2.0),
			markersize=8, markerstrokewidth=0,
			ylabel="Mean cell numbers", grid=false,
			legend=false)
	plot!(size=(200,200))
end

# ╔═╡ 7f11092e-f5f6-11ea-202a-354e1ffff2aa
md"###### Exercise (optional): Transfer the code to an editor of your choice (Python, R, Matlab) and compare the runtimes with the Julia version!"

# ╔═╡ 05ed29fa-f5f7-11ea-2fa0-49e3cebdbaf5
md"""
Check box to show solution $(@bind gill_sol html"<input type=checkbox >")
"""

# ╔═╡ e4c648e2-f5d8-11ea-22cb-0b702165e418
md"## 3. DifferentialEquations.jl"

# ╔═╡ 06d00ba8-f53e-11ea-0954-437217397654
md"""_An ordinary differential equation (ODE) model_

Below you find an ODE model for the famous [Lotka-Volterra](https://en.wikipedia.org/wiki/Lotka%E2%80%93Volterra_equations) system; an example of pre-ancient theoretical biology (starting around 1910-ish). It describes predator-prey relationships.

$(PlutoUI.LocalResource("images/pred_prey.png", :width => 300))
"""

# ╔═╡ 125d18a0-f53c-11ea-10c5-8f872fb3a1b6
function lotka_volterra(du, u, θ, t)
    x, y = u
    α, β, γ, δ = θ
    du[1] = (α - β*y)x # dx =
    du[2] = (δ*x - γ)y # dy =
end;

# ╔═╡ ba08c824-f53c-11ea-102e-89474ff586c1
begin
	α_slider = @bind α html"<input type='range' min='0.0' max='4.0' step='0.1' value='1.5'>"
	β_slider = @bind β html"<input type='range' min='0.0' max='4.0' step='0.1' value='1.0'>"
	γ_slider = @bind γ html"<input type='range' min='0.0' max='4.0' step='0.1' value='3.0'>"
	δ_slider = @bind δ html"<input type='range' min='0.0' max='4.0' step='0.1' value='1.0'>"

	md"""
	α = $(α_slider)

	β = $(β_slider)

	γ = $(γ_slider)

	δ = $(δ_slider)"""
end

# ╔═╡ 469d90cc-f6bd-11ea-25d0-5d91fb1b390e
[α, β, γ, δ];

# ╔═╡ 3169ab5a-f53c-11ea-20c7-4d9c8a6755ed
begin
	θ = [α, β, γ, δ]
	u0 = [1.0, 1.0]
	prob_lv = ODEProblem(lotka_volterra, u0, (0.0,10.0), θ)
	sol_lv = solve(prob_lv, Tsit5())
end;

# ╔═╡ 371a5018-f53c-11ea-336e-c3b7cca672ca
begin
	plot(sol_lv, linewidth=4, xlabel="Time", ylabel="Population size",
		grid=false)
	plot!(size=(350,200))
end

# ╔═╡ 973c748a-f6b8-11ea-35a3-afd13d5cdc20
md"###### Exercise: 
- **Which variable is prey? Which is predator?**
- **What do the parameters _α_, _β_, _γ_ and _δ_ mean biologically?**
"

# ╔═╡ 6a3ffd6a-f6ba-11ea-21f7-7db8dbd4c2a8
md"""
Check box to show solution $(@bind pacman_sol html"<input type=checkbox >")
"""

# ╔═╡ 0f776d76-f6b7-11ea-3844-357b88767e4d
md"_What else does DifferentialEquations.jl offer? Basically everything..._
- Discrete equations (function maps, discrete stochastic (Gillespie/Markov) simulations)
- Ordinary differential equations (ODEs)
- Split and Partitioned ODEs (Symplectic integrators, IMEX Methods)
- Stochastic ordinary differential equations (SODEs or SDEs)
- Random differential equations (RODEs or RDEs)
- Algebraic differential equations (DAEs)
- Delay differential equations (DDEs)
- Mixed discrete and continuous equations (Hybrid Equations, Jump Diffusions)
- (Stochastic) partial differential equations ((S)PDEs) (with both finite difference and finite element methods)

And a whole ecosystem around it ([SciML](https://github.com/SciML)):
- Parameter estimation
- Sensitivity analysis
- Bayesian inference
- Neural networks + Differential equations
- ...
"

# ╔═╡ 4bb6e490-f533-11ea-269b-ef6f31e561c5
md"
## 4. Turing.jl"

# ╔═╡ ba139b34-f5fd-11ea-3a81-6d7937c50945
md"""###### Bayesian inference with probabilistic programming (Poisson example)

$(PlutoUI.LocalResource("images/bayes.png", :width => 650))

Let's load some data: (two data sets available data5 and data50)
"""

# ╔═╡ e57c6d64-f5e2-11ea-3c20-a787e4ea581e
data_poisson_dict = load("data/data_poisson.jld");

# ╔═╡ 6c685eda-f533-11ea-3493-c5310df8c643
data_poisson = data_poisson_dict["data50"];

# ╔═╡ 4a67c670-f533-11ea-16ab-7722dbb259e0
begin
	histogram(data_poisson, bins=range(-0.5, 24.5, step=1),
            normalize=true, label="Data", xlabel="mRNA numbers",
            ylabel="Probability density", linecolor=:match)
	plot!(size=(350,200))
end

# ╔═╡ ceef3b0a-f53d-11ea-0c89-6f825163bb2a
md"Define a prior:"

# ╔═╡ 43950fba-f5fd-11ea-1129-9b241561e88c
begin
	gamma_α = 5
	λ_poi_prior = Gamma(gamma_α, 1) # Uniform(0, 20) # Uniform(0, 5)
end;

# ╔═╡ bec8e190-f533-11ea-2435-71f946622b6f
begin
	plot(range(0, stop=20, length=1000), linewidth=4,
		λ_poi_prior, xlabel="λ", ylabel="Probability",
		label="p(λ)", color=:darkorange)
	plot!(size=(350,200))
end

# ╔═╡ ebc69e62-f53d-11ea-0e3d-4b66434f2a1a
md"Set up the Turing model:"

# ╔═╡ 2befcf68-f534-11ea-1507-9dd8e6d7dc8b
@model function poisson_fit(data_poisson)
	λ ~ λ_poi_prior
	for i in 1:length(data_poisson)
		data_poisson[i] ~ Poisson(λ)
	end
end;

# ╔═╡ f860a12c-f53d-11ea-0a1f-41a6316cca01
md"Run the inference:"

# ╔═╡ 0105a34c-f534-11ea-3b4a-234436973165
begin
	iterations = 1000
	ϵ = 0.05
	τ = 10
	chain_poi = sample(poisson_fit(data_poisson), HMC(ϵ, τ), iterations)
end;

# ╔═╡ 755b4af6-f534-11ea-239c-03b4eb8672af
begin
	plot(chain_poi[:λ], label="λ|D samples", linecolor=:tomato,
        xlabel="MCMC iterations", ylabel="λ",
        legend=:best)
	plot!(size=(350,200))
end

# ╔═╡ 7086f572-f534-11ea-0cd0-0fc9d6f2a56d
begin
	histogram(chain_poi[:λ].data[100:end], color=:tomato,
	                normalize=true, label="p(λ | D) [Posterior]",
	                linecolor=:match, xlabel="λ", ylabel="Probability");
	plot!(range(0, stop=15, length=1000), linewidth=4,
	                λ_poi_prior, legend=:topleft,
	                label="p(λ) [Prior]", color=:darkorange);

	if typeof(λ_poi_prior)==Gamma{Float64}
		plot!(range(0, stop=15, length=1000), linewidth=4,
						Gamma(gamma_α + sum(data_poisson),1/(length(data_poisson)+1)),
						label="p(λ | D) [Analytical]", color=:red,
						legend=:topleft)
	end
	plot!(size=(350,200))
end

# ╔═╡ 21787c78-f60c-11ea-2ece-a7002bb43929
begin
	histogram(data_poisson, bins=range(-0.5, 24.5, step=1),
            normalize=true, label="Data", xlabel="mRNA numbers",
            ylabel="Probability density", linecolor=:match)
	plot!(Poisson(chain_poi[:λ].data[100:end][1]), grid=false, label="Poisson(λ | D)",
			linewidth=1, color=:darkorange, markerstrokewidth=0,
			alpha=1.0, markersize=1.0)
	for i in 2:100
		plot!(Poisson(chain_poi[:λ].data[100:end][i]), grid=false, label=false,
			linewidth=2, color=:darkorange, markerstrokewidth=0,
			alpha=0.1, markersize=0.0)
	end
	plot!(size=(350,200))
end

# ╔═╡ 16956c34-f5db-11ea-35d6-37965c71b5d6
md"###### Exercise: Change the Gamma prior to an Uniform prior! Which kind of uniform prior is a good choice?"

# ╔═╡ 7f361ad8-f5e0-11ea-3d76-0b801f0ed798
md"""
Check box to show solution $(@bind turing_sol html"<input type=checkbox >")
"""

# ╔═╡ f28a092c-f606-11ea-0970-87679e72268a
md"###### Some theoretical background for this example
_Using Bayesian inference: How to learn something about a parameter θ of a model M given some data D?_ We first interpret _θ_ and _D_ as random variables. We then incorporate (subjective) prior knowledge about _θ_ as a probability distribution _p(θ)_ (the 'prior'). Our goal is now to calculate the 'posterior' _p(θ|D)_ (the new information for _θ_ given the data _D_). To get this we use Bayes' rule:
$ p(\theta | D) = \frac{p(D|\theta) \cdot p(\theta)}{p(D)} $ (in words, _posterior_ = _likelihood_ x _prior_ / _evidence_ ).

_What is probabilistic programming?_ Probabilistic programming is a programming paradigm in which probabilistic models are specified and inference for these models is performed automatically. It represents an attempt to unify probabilistic modeling and traditional general purpose programming in order to make the former easier and more widely applicable (ref: [Wiki](https://en.wikipedia.org/wiki/Probabilistic_programming)).

_Constitutive mRNA expression at steady state:_ The stationary/steady state distribution for mRNA numbers _X_ with linear, constant synthesis and degradation rates _γ_ and _δ_ can be shown to be the Poisson distribution $X \sim \textrm{Poi}(λ)$ with $λ = \frac{γ}{δ}$. Further, to get an analytical result for the posterior _p(λ|D)_, we will make use of the Gamma distribution as its a conjugate prior to the Poisson likelihood; we have _p(λ|D)_ (Gamma) ∝ _p(D|λ)_ (Poisson) x _p(λ)_ (Gamma).
"

# ╔═╡ 15140a86-f53c-11ea-0c46-35d1d46c2bc3
md"## 5. Turing.jl and DifferentialEquations.jl"

# ╔═╡ b148839c-f60a-11ea-3059-2f6bf0a75572
md"""###### Simple division process, continued
\
$(PlutoUI.LocalResource("images/gillespie.png", :width => 800))

_What we have learned so far:_
- Principles of Julia, basic syntax, performance tips
- How to Gillespie-simulate a simple cell division process
- How to run Differential Equations in Julia
- How to estimate model parameters using Turing

_Now let's bring it all together! Goal of this last part:_
- Use our Gillespie algorithm to create some _in silico_ data for the division process
- Use DifferentialEquations.jl to build an ODE model for the mean cell numbers
- Use Turing.jl on top of that to estimate our ODE model parameters, given our Gillespie data!
"""

# ╔═╡ 320f6e6c-f53e-11ea-2ddd-93d646f77c70
md"**1.** Create some _in silico_ data (with our 'true' parameter value for λ):"

# ╔═╡ a98db496-f60e-11ea-2c6f-cdab1fdb9bdd
begin
	init_cells = 1 # initial cell number
	λrate = 2.0 # division rate
	timespan = 3.0 # time range to simulate
	datapoints = 40 # number of simulation repeats

	# Gillespie simulations
	gill_data = gillespie_alg(init_cells, λrate, timespan, datapoints)
end;

# ╔═╡ 438e9380-f60f-11ea-1d92-83ee6cd05bd6
begin
	scatter([timespan for i in 1:100], gill_data,
			xlim=(0, timespan*1.1), ylim=(0, maximum(gill_data)*1.2),
			ylabel="Cell number", xlabel="Time", label="Data",
			alpha=0.2, markerstrokewidth=0.0, legend=:topleft)
	plot!(size=(350,200))
end

# ╔═╡ f81e5ba4-f610-11ea-2c71-d58314c78178
md"**2.** Build an ODE model:

###### Exercise: Complete the function `simple_div_ode` (below) with the correct ODE model!
"

# ╔═╡ 7a4625aa-f6be-11ea-2e78-0dbb649d93c2
md"""
Check box to show solution $(@bind div_check_sol1 html"<input type=checkbox >")
"""

# ╔═╡ 029e6272-f611-11ea-2790-89643a23244b
function simple_div_ode(du, u, θ, t)
    ### ADD YOUR CODE HERE (replace nothing)
	# nothing
	du[1] = θ[1] * u[1]
end;

# ╔═╡ 3fa255be-f611-11ea-351f-ff1c61d0a44c
begin
	prob_div = ODEProblem(simple_div_ode, [init_cells],
							(0.0, timespan), [λrate])
	sol_div = solve(prob_div, Tsit5())
end;

# ╔═╡ c592c872-f611-11ea-2a6c-3f59da5d4970
begin
	plot(sol_div, alpha=0.3, legend = false, linewidth=4,
        xlabel="Time", ylabel="Cell number", label="Mean model (true λ)");
	scatter!([timespan for i in 1:100], gill_data, c=:dodgerblue,
			xlim=(0, timespan*1.1), ylim=(0, maximum(gill_data)*1.2),
			ylabel="Cell number", xlabel="Time", label="Data",
			alpha=0.2, markerstrokewidth=0.0, legend=:topleft)
	plot!(size=(350,200))
end

# ╔═╡ 75f975b2-f612-11ea-1acf-9f0e13327774
md"**3.** Setup the Turing model:

###### Exercise (for the experts): Complete the Turing model below, assuming a Normal/Gaussian error model for our likelihood!"

# ╔═╡ 0709c758-f6c4-11ea-1167-09a125771539
md"""
Check box to show solution $(@bind div_check_sol2 html"<input type=checkbox >")
"""

# ╔═╡ 420e7070-f614-11ea-155a-c18fc549f2cd
# priors 
# (used for plotting, should be identical to priors in our Tuing model)
begin
	λest_prior = Uniform(0.0, 4.0)
	σ_div_prior = Uniform(0, 800)
end;

# ╔═╡ 9aa70686-f614-11ea-2767-39ec8e428137
begin
	plot(λest_prior, linewidth=4,
		xlabel="λ", ylabel="Probability",
		label="p(λ)", color=:darkorange)
	plot!(size=(350,200))
end

# ╔═╡ 2e082e5c-f616-11ea-1e64-c55552c523df
begin
	plot(σ_div_prior, linewidth=4,
		xlabel="σ", ylabel="Probability",
		label="p(σ)", color=:red)
	plot!(size=(350,200))
end

# ╔═╡ a41686d8-f612-11ea-0b06-e7ca3f9dfaeb
begin
	@model function simple_div_fit(gill_data)
		λest ~ Uniform(0.0, 4.0)
		σdiv ~ Uniform(0, 800)

		# save_everystep=false provides only the last time point
		prob = remake(prob_div, p=[λest])
		μdiv = solve(prob,Tsit5(), save_everystep=false)

		for i in 1:length(gill_data)
			### ADD YOUR CODE HERE (replace nothing)
			# nothing
			gill_data[i] ~ Normal(μdiv[2][1], σdiv)
		end
	end
end;

# ╔═╡ 7ba8de66-f61d-11ea-1a1c-c5e3e7b0ef54
md"**4.** Bayesian inference:

_Enjoy fast Julia code for fitting an ODE model with full Bayesian inference in just under one second!_ :)

_(Note: We use a gradient-based sampler; automatic differentiation is carried through the complete Turing model including our ODE, which makes this fast)_"

# ╔═╡ c91c64d8-f613-11ea-01bd-c55b35610e15
chain_div = sample(simple_div_fit(gill_data), NUTS(.65), 1000);

# ╔═╡ 53036722-f615-11ea-1526-59fb62500060
begin
	histogram(chain_div[:σdiv].data[200:end], color=:tomato,
	                normalize=true, label="p(σ | D) [Posterior]",
	                linecolor=:match);
	plot!(σ_div_prior, linewidth=4,
		xlabel="σ", ylabel="Probability",
		label="p(σ) [Prior]", color=:red)
	plot!(size=(350,200))
end

# ╔═╡ 68611d20-f616-11ea-1a48-ff9b9b125b24
begin
	histogram(chain_div[:λest].data[200:end], color=:darkorange,
	                normalize=true, label="p(λ | D) [Posterior]",
	                linecolor=:match);
	plot!(λest_prior, linewidth=4,
		xlabel="λ", ylabel="Probability",
		label="p(λ) [Prior]", color=:darkorange)
	plot!(size=(350,200))
end

# ╔═╡ b5967680-f61b-11ea-29ff-e151fd817baf
begin
	scatter([timespan for i in 1:100], gill_data, c=:dodgerblue,
			label="Data", alpha=0.2, markerstrokewidth=0.0)
	prob = remake(prob_div, p=[chain_div[:λest].data[200:end][1]])
	predicted = solve(prob,Tsit5())
	plot!(predicted, alpha=1.0, label="Fits", linewidth=1, c=:dodgerblue);
	for i in 2:100
		prob = remake(prob_div, p=[chain_div[:λest].data[200:end][i]])
		predicted = solve(prob,Tsit5())
		plot!(predicted, alpha=0.2, linewidth=1, label=false, c=:dodgerblue);
	end
	plot!(sol_div, alpha=1.0, linewidth=2, c="black", label="True model",
		ylabel="Cell number", xlabel="Time", legend=:topleft,
		xlim=(0, timespan*1.1), ylim=(0, maximum(gill_data)*1.2));
	plot!(size=(350,200))
end

# ╔═╡ 51813362-f619-11ea-16f8-2101534d2881
# plot(chain_div)

# ╔═╡ 08da756c-f51d-11ea-2167-61055a2ba344
md""" 
## 6. Further Information and References

### Some valuable links
- [Julia Website](https://julialang.org/)
- [Julia Documentation](https://docs.julialang.org/en/v1/)
- [Julia Discourse Forum](https://discourse.julialang.org/) (ideal for asking questions!)
- [A concise Julia tutorial](https://syl1.gitbook.io/julia-language-a-concise-tutorial/)
- [JuliaPro from JuliaComputing](https://juliacomputing.com/products/juliapro) (like a conda installation for Python)
- [JuliaAcademy](https://juliaacademy.com/) (free course material)
\

### Editors/Programming Environments for Julia

_Editors_
- [Juno (in Atom)](https://junolab.org/) (current standard)
- [VS Code extension](https://github.com/julia-vscode/julia-vscode) (maybe the future standard)

_Notebooks_
- [Jupyter Lab/Notebook](https://jupyter.org/) (if you have Jupyter already just install [IJulia](https://github.com/JuliaLang/IJulia.jl) on top)
- [Pluto.jl](https://github.com/fonsp/Pluto.jl) (used here)
\

### Packages and Ecosystems

Larger ecosystems
- [SciML](https://github.com/SciML) - _Open Source Scientific Machine Learning_
- [The Turing Language](https://github.com/TuringLang) - _Bayesian inference with probabilistic programming_
- [Flux](https://github.com/FluxML/Flux.jl) - _Pure-Julia approach to machine learning with Julia's native GPU and AD support_
- [JuliaStats](https://github.com/JuliaStats) - _Statistics and Machine Learning made easy in Julia_
- [BioJulia](https://github.com/BioJulia) - _Bioinformatics and Computational Biology in Julia_
- [JuliaGraphs](https://github.com/JuliaGraphs) - _Graph modeling and analysis packages for Julia_
- [JuMP](https://github.com/jump-dev/JuMP.jl) - _Modeling language for Mathematical Optimization_
- [JuliaIO](https://github.com/JuliaIO) - _Group for a unified IO infrastructure_

More particular packages (sometimes part of ecosystems above)
- [DifferentialEquations](https://github.com/SciML/DifferentialEquations.jl) - _Multi-language suite for high-performance solvers of differential equations_
- [DataFrames](https://github.com/JuliaData/DataFrames.jl) - _In-memory tabular data in Julia_
- [Distributions](https://github.com/JuliaStats/Distributions.jl) - _Julia package for probability distributions and associated functions_
- [Zygote](https://github.com/FluxML/Zygote.jl) - _next-gen automatic differentiation (AD) system for source-to-source AD in Julia_
- [KissABC](https://github.com/JuliaApproxInference/KissABC.jl) - _Pure julia implementation for efficient Approximate Bayesian Computation_
- [NestedSamplers](https://github.com/TuringLang/NestedSamplers.jl) - _Implementations of single and multi-ellipsoid nested sampling_

Performance packages
- [BenchmarkTools](https://github.com/JuliaCI/BenchmarkTools.jl) - _A benchmarking framework for the Julia language_
- [ProfileView](https://github.com/timholy/ProfileView.jl) - _Visualization of Julia profiling data_

Notebooks/Visualisation
- [Plots](https://github.com/JuliaPlots/Plots.jl) - _Powerful convenience for Julia visualizations and data analysis_
- [Pluto](https://github.com/fonsp/Pluto.jl) - _Lightweight reactive notebooks for Julia_
- [IJulia](https://github.com/JuliaLang/IJulia.jl) - _Julia kernel for Jupyter_

"""

# ╔═╡ ead9e534-f620-11ea-18c6-b356e37fe51a
md"""
\
\
\
"""

# ╔═╡ 030c9e10-f61e-11ea-2080-1325c8e8cd3b
md"""
### _Well done, that's all!_
\
\
\
\
\
\
\
\
"""

# ╔═╡ 135fff12-f69f-11ea-3f00-45aa2f5c340b
begin
	md"""### Presenter's notes

	_Time management_
	1) Introduction to Julia **18 min.**
	2) Performance tips and a Gillespie algorithm **18 min.**
	3) Differential Equations in Julia **18 min.**
	4) Bayesian Inference and Probabilistic Programming **18 min.**
	5) _Everything from above combined :)_ **18 min.**
	6) Further Information/References **0 min.**
	7) Total = 5 * 18 min. = 90 min.

	_Example formula_
	$ \frac{dx}{dt} = \alpha x $

	_Example table_

	Meaning | Variable
	:------ | :--------:
	Number of people | people
	Average number of slices each person eats | avg
	Number of slices on a piece of pizza | slices

	_Example box_
	"""
end

# ╔═╡ 30f297be-f6a3-11ea-0509-6db3c3648a8b
begin
	almost(text) = Markdown.MD(Markdown.Admonition("warning", " ", [text]));


	keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "", [text]));

	correct(text=md"Great! You got the right answer! Let's move on to the next section.") = Markdown.MD(Markdown.Admonition("correct", "Solution", [text]));

	pizzas=4

	if pizzas == 4
		correct(md"Yes that is right, that's a lot of pizza! Excellent, you figured out we need to round up the number of pizzas!")
	else
		keep_working()
	end
end

# ╔═╡ 13716104-f5e8-11ea-0c9f-ef295bf6d732
if perf_sol_1
	correct(md"A benchmark test with the `@btime` macro would provide something like this:\
		v1: `18.992 μs (0 allocations: 0 bytes)`\
v2: `46.368 μs (2 allocations: 781.33 KiB)`\
v3: `19.052 μs (0 allocations: 0 bytes)`

Why? First of all, for-loops are fast in Julia (unlike Python, R, ...)! Thus v3 is as fast as the correctly vectorised/fused version v1 (which actually compiles down to the same for-loop as in v3). v2 is slower because it requires memory allocations to save the intermediate results for all indices (`3*x`) before referencing them to `x` again.
		")
else
	almost(md"You will do it!")
end

# ╔═╡ 0a1cc0f0-f5ed-11ea-27ab-efcc5eff1969
if perf_sol_2
	correct(md"In-place functions receive an input (here `x`) and instead of storing results in a new array `y` they will directly store the results in `x` itself by overriding its memory. In our case v1 is in-place and v2 is not; in v1 `x` will change when the function is called while in v2 `x` stays the same. In-place functions are much faster as they don't need to allocate new memory; our benchmark result with the `@btime` macro:\
v1: `19.479 μs (0 allocations: 0 bytes)`\
v2: `77.648 μs (2 allocations: 781.33 KiB)`\
As a convention, in-place functions in Julia are indicated by an `!` at the end of the function name. All functions in Exercise 1 were also in-place.")
else
	almost(md"You will do it!")
end

# ╔═╡ cfe99310-f5f2-11ea-1448-29fede30e23b
if perf_sol_3
	correct(md"Type-stable code means that Julia can infer concrete types for the variables at the start of the program (e.g., `Int64` or `Float64`) that are stable/do not change throughout the remaining part. v2 is type-stable since `x` will start as a float (`x=1.0`) and stays a float until the end. v1 has a type-instability: `x` starts as an integer (`x=1`) but is later changed to a float. Type-stable code allows Julia to dispatch fast specialised methods for the concrete types during compilation. Type-instable variables have to be checked at runtime what they actually are, which is a performance killer:\
v1: `7.109 ns (0 allocations: 0 bytes)`\
v2: `1.596 ns (0 allocations: 0 bytes)`\
Note that v1 will still get the same correct result (`0.0009765625`), to write type-stable code increases performance but you don't have to care if runtime is not important!
Type-instabilities can be easily found with the `@code_warntype` macro.")
else
	almost(md"You will do it!")
end

# ╔═╡ 2bb71a58-f5f7-11ea-093e-43fd313917f3
if gill_sol
	correct(md"With `n = 10000` repeats, the Julia version runs with about `39.343 ms (2 allocations: 78.20 KiB)`. A Python version of the same code required about
		8.3 seconds, thus Julia is over 200 times faster!")
else
	almost(md"You will do it!")
end

# ╔═╡ 6b2dbf0a-f6ba-11ea-37b7-f32440c09b60
if pacman_sol
	correct(md"`x` is the number of prey (for example, rabbits); `y` is the number of predator (for example, foxes); α reproduction rate of prey; β predation rate; γ predator death rate; δ reproduction rate of predator per prey.")
else
	almost(md"You will do it!")
end

# ╔═╡ 7cc5fd84-f5e0-11ea-1391-f7e79d3406eb
if turing_sol
	correct(md"In the box above you can replace `λ_poi_prior = Gamma(gamma_α, 1)`
		with `λ_poi_prior = Uniform(0, 20)`. `0` and `20` are possible choices. What is a good choice? Our only prior knowledge is that mRNA numbers are non-negative, so `0` is reasonable as lower bound. For the upper bound we don't have that much info, so maybe take something large compared to the data outcomes (e.g., 20). To see what would happen if you constrain the prior too much, enter `Uniform(0, 5)` for example.")
else
	almost(md"You will do it!")
end

# ╔═╡ 6115aa3c-f6bf-11ea-14b7-0568795a08d7
if div_check_sol1
	correct(md"For the mean cell numbers we have simple linear ODE, modelling exponential growth: `du[1] = θ[1] * u[1]` will do it. (In mathematical terms, this is $\frac{\textrm{d}x(t)}{\textrm{d}t} = \lambda \cdot x(t)$.)")
else
	almost(md"You will do it!")
end

# ╔═╡ 0da2224a-f6c4-11ea-1b3e-bd9dbf04ee57
if div_check_sol2
	correct(md"For a normal error model we make use of the Normal distribution with mean parameter `μ` and standard deviation `σ`. The mean comes from our ODE solution; the standard deviation is estimated as part of our model. To implement this, you can use this code: `Normal(μdiv[2][1], σdiv)`. Then the inference should start running. (The weird indexing in `μdiv[2][1]` is just to read out the mean cell numbers of our ODE solution.)")
else
	almost(md"You will do it!")
end

# ╔═╡ 99c902ca-f52a-11ea-29c7-13394ff733c5
begin
	md"""
	_Example input types_

	`a = ` $(@bind a html"<input type=range >")

	`b = ` $(@bind b html"<input type=text >")

	`c = ` $(@bind c html"<input type=button value='Click'>")

	`d = ` $(@bind d html"<input type=checkbox >")

	`e = ` $(@bind e html"<select><option value='one'>First</option><option value='two'>Second</option></select>")

	`f = ` $(@bind f html"<input type=color >")
	"""
end

# ╔═╡ b2e0752c-f52a-11ea-0a58-df9764cfb38c
(a, b, c, d, e, f)

# ╔═╡ Cell order:
# ╟─350c6846-f52e-11ea-2c8e-69d7aaadebbe
# ╟─ba641ca0-f678-11ea-2517-4f85ea4d3423
# ╟─3d9f3eec-f665-11ea-2b71-678afc915989
# ╟─f3c20672-f51c-11ea-3303-cd9b65133594
# ╟─2d1f4f7a-f52b-11ea-0c75-cd873132c58d
# ╟─b2b071e6-f6a4-11ea-2962-593a281afa51
# ╟─debd8066-f52e-11ea-03d7-55093d4d50ff
# ╟─b60cf1a8-f525-11ea-1476-4787760c3654
# ╟─fd8a6856-f5bd-11ea-0394-655187f55a4a
# ╟─de89e6ba-f5be-11ea-35e1-1dbfda29ca4a
# ╟─38bcd576-f69f-11ea-04b6-5b497457c85a
# ╟─37109e76-f5c1-11ea-196d-99c2ac49a062
# ╟─aa95fe4e-f5c2-11ea-08e3-715fd74b8947
# ╟─7575f402-f5d0-11ea-05f4-75eb4096930d
# ╟─fb7d2fc8-f6b5-11ea-2d3d-c566c4292a4c
# ╠═065885ca-f6b4-11ea-39ee-bbca217e81d7
# ╠═0766c508-f6b4-11ea-2776-d100ed8c4b7e
# ╟─1c0dde9c-f6b4-11ea-38d9-af2e85e6dad9
# ╠═2341a2b6-f6b4-11ea-3946-97e162f449ce
# ╠═280b5d30-f6b4-11ea-32bf-4dd537092235
# ╟─5fd479ec-f6b4-11ea-199f-630771b2dac3
# ╠═63bad2e0-f6b4-11ea-24dc-c93e9fec1259
# ╟─6ef88076-f6b4-11ea-2625-91fa654744e4
# ╠═79f18f18-f6b4-11ea-2833-b1bf5cf2adb6
# ╠═7dd62f6c-f6b4-11ea-391f-df2994da3551
# ╟─d8bca430-f6b5-11ea-085d-839f76472e31
# ╠═db5c71e0-f6b5-11ea-2259-01d0e71302d6
# ╟─dee751ae-f6b5-11ea-332d-f7fd57b88a3d
# ╠═e6d2f22e-f6b5-11ea-1d89-dda69d6b459c
# ╟─fb7f685a-f5d0-11ea-13f5-ed782705b7c7
# ╠═c89da684-f6b5-11ea-2fa1-43ecc44703f3
# ╠═edf4ea28-f5d2-11ea-02d4-43772be1576a
# ╠═6f18bc2a-f5d2-11ea-12c3-875a26c75ef6
# ╠═da13abe8-f5d2-11ea-1614-afd878920560
# ╟─0411bfac-f5d3-11ea-2f0f-a5a2bdce4f65
# ╠═0ed01aec-f5d3-11ea-1ff1-5d2d6e6cad8e
# ╠═5a4690a0-f5d3-11ea-1b4e-238ee7fa9f09
# ╟─da64181c-f532-11ea-2276-33baf092559c
# ╟─a94ffb96-f5d3-11ea-2b91-0d12431f2e80
# ╠═5dc2ca7c-f539-11ea-2892-8f03b5d76228
# ╠═767fe0f4-f539-11ea-0bda-b9bd8022123a
# ╠═0a9b4b4a-f533-11ea-0783-8963ceaa253d
# ╠═06cde658-f533-11ea-287a-a99d49e6850c
# ╠═f4a72ea8-f532-11ea-0eba-0138545cdf04
# ╟─b0fe25d8-f539-11ea-0cde-3f14645b6c13
# ╟─db517cd6-f5cf-11ea-0242-d9a8e320af62
# ╠═ba023b24-f539-11ea-2aee-a1cfc56b550a
# ╠═bf5f7276-f539-11ea-0b05-23e37b1397d0
# ╠═bf603706-f539-11ea-28b1-37dcd5886481
# ╠═bf613c0a-f539-11ea-1d72-45c9cafdf08c
# ╟─09b829b2-f5d0-11ea-227d-675f3c591d74
# ╠═bf690c08-f539-11ea-1cdd-f7f79d127e0d
# ╠═bf75ba66-f539-11ea-368a-7bdddb507a95
# ╠═bf89a866-f539-11ea-3292-0f991a288db8
# ╠═bf9003be-f539-11ea-2931-098d4e8a2e8b
# ╟─396a7e4e-f5d0-11ea-3f51-b1243e3dec08
# ╠═bfa5ddd6-f539-11ea-0c3b-1fd74faabeb1
# ╠═bfac62ae-f539-11ea-0779-49c930964691
# ╠═bfb5ce64-f539-11ea-2007-9b250e84943a
# ╠═bfca9fa8-f539-11ea-1181-754865c85895
# ╠═bfd4beb4-f539-11ea-3beb-ebd2a9f9f55c
# ╠═bfe423ae-f539-11ea-1d57-7117ca16fd59
# ╟─12332104-f53b-11ea-01f7-a783beffc4ee
# ╟─5e03ea98-f5d4-11ea-153b-675bbcb96db8
# ╟─aa0ff2c6-f5d4-11ea-384d-a755ddf9c74d
# ╠═636f2bd6-f5d5-11ea-3bb2-291598e50a49
# ╠═5afbaa4a-f73a-11ea-21fb-d97cede4684f
# ╠═9c598a9a-f5d5-11ea-39f6-9b979b95c256
# ╠═a53bb566-f5d5-11ea-13f4-05fb39073a0c
# ╠═05f26410-f5d6-11ea-37c4-f34c9fde0d5d
# ╟─fd514fe6-f5d4-11ea-01cd-97f28ebb6227
# ╠═22757d6c-f53b-11ea-3eae-7ffd8723a4eb
# ╠═19d97250-f53b-11ea-05a4-254304584485
# ╠═4d7b6294-f53b-11ea-0d5e-0d5184dadcb2
# ╠═4d7d1b52-f53b-11ea-0bc8-4d1082ff0f8e
# ╟─31f8eaa4-f541-11ea-1cde-39e63f4aebea
# ╟─9d41be3a-f541-11ea-3b45-6f931e2ad603
# ╠═adfe85be-f541-11ea-2c9a-d778b46ab90c
# ╠═64832bf6-f624-11ea-0f57-3790031bf7a8
# ╟─247df138-f5e8-11ea-310c-79b55d7210b1
# ╟─13716104-f5e8-11ea-0c9f-ef295bf6d732
# ╟─7e228aa2-f541-11ea-1ce8-4bf43de2136f
# ╠═8a150498-f541-11ea-1374-652ca1454e76
# ╟─0263d3ba-f5ed-11ea-3916-95349ae429d9
# ╟─0a1cc0f0-f5ed-11ea-27ab-efcc5eff1969
# ╟─af7db644-f541-11ea-3dc7-c928e53b59db
# ╠═1869719a-f542-11ea-0186-7bae357a73c5
# ╟─ca8274e6-f5f2-11ea-293a-4953cd8d69be
# ╟─cfe99310-f5f2-11ea-1448-29fede30e23b
# ╟─7d4a47d8-f542-11ea-1f7d-53ab0e4ff0a1
# ╟─3efacc48-f541-11ea-0625-d1212cac1820
# ╠═b1ade5f4-f543-11ea-2a29-1fdc5e7acbcb
# ╟─118f1fac-f5f7-11ea-21ec-431225a36961
# ╠═22e5cb2a-f5f7-11ea-3bc2-678184795816
# ╠═59675060-f5f7-11ea-246a-f302300481df
# ╠═5bb3ac56-f5f7-11ea-3fae-7f83b84cb6da
# ╟─73888418-f5f8-11ea-2b7c-297e6395e395
# ╟─7f11092e-f5f6-11ea-202a-354e1ffff2aa
# ╟─05ed29fa-f5f7-11ea-2fa0-49e3cebdbaf5
# ╟─2bb71a58-f5f7-11ea-093e-43fd313917f3
# ╟─e4c648e2-f5d8-11ea-22cb-0b702165e418
# ╟─06d00ba8-f53e-11ea-0954-437217397654
# ╠═125d18a0-f53c-11ea-10c5-8f872fb3a1b6
# ╟─ba08c824-f53c-11ea-102e-89474ff586c1
# ╠═469d90cc-f6bd-11ea-25d0-5d91fb1b390e
# ╠═3169ab5a-f53c-11ea-20c7-4d9c8a6755ed
# ╠═371a5018-f53c-11ea-336e-c3b7cca672ca
# ╟─973c748a-f6b8-11ea-35a3-afd13d5cdc20
# ╟─6a3ffd6a-f6ba-11ea-21f7-7db8dbd4c2a8
# ╟─6b2dbf0a-f6ba-11ea-37b7-f32440c09b60
# ╟─0f776d76-f6b7-11ea-3844-357b88767e4d
# ╟─4bb6e490-f533-11ea-269b-ef6f31e561c5
# ╟─ba139b34-f5fd-11ea-3a81-6d7937c50945
# ╠═e57c6d64-f5e2-11ea-3c20-a787e4ea581e
# ╠═6c685eda-f533-11ea-3493-c5310df8c643
# ╟─4a67c670-f533-11ea-16ab-7722dbb259e0
# ╟─ceef3b0a-f53d-11ea-0c89-6f825163bb2a
# ╠═43950fba-f5fd-11ea-1129-9b241561e88c
# ╟─bec8e190-f533-11ea-2435-71f946622b6f
# ╟─ebc69e62-f53d-11ea-0e3d-4b66434f2a1a
# ╠═2befcf68-f534-11ea-1507-9dd8e6d7dc8b
# ╟─f860a12c-f53d-11ea-0a1f-41a6316cca01
# ╠═0105a34c-f534-11ea-3b4a-234436973165
# ╟─755b4af6-f534-11ea-239c-03b4eb8672af
# ╟─7086f572-f534-11ea-0cd0-0fc9d6f2a56d
# ╟─21787c78-f60c-11ea-2ece-a7002bb43929
# ╟─16956c34-f5db-11ea-35d6-37965c71b5d6
# ╟─7f361ad8-f5e0-11ea-3d76-0b801f0ed798
# ╟─7cc5fd84-f5e0-11ea-1391-f7e79d3406eb
# ╟─f28a092c-f606-11ea-0970-87679e72268a
# ╟─15140a86-f53c-11ea-0c46-35d1d46c2bc3
# ╟─b148839c-f60a-11ea-3059-2f6bf0a75572
# ╟─320f6e6c-f53e-11ea-2ddd-93d646f77c70
# ╠═a98db496-f60e-11ea-2c6f-cdab1fdb9bdd
# ╟─438e9380-f60f-11ea-1d92-83ee6cd05bd6
# ╟─f81e5ba4-f610-11ea-2c71-d58314c78178
# ╟─7a4625aa-f6be-11ea-2e78-0dbb649d93c2
# ╟─6115aa3c-f6bf-11ea-14b7-0568795a08d7
# ╠═029e6272-f611-11ea-2790-89643a23244b
# ╠═3fa255be-f611-11ea-351f-ff1c61d0a44c
# ╟─c592c872-f611-11ea-2a6c-3f59da5d4970
# ╟─75f975b2-f612-11ea-1acf-9f0e13327774
# ╟─0709c758-f6c4-11ea-1167-09a125771539
# ╟─0da2224a-f6c4-11ea-1b3e-bd9dbf04ee57
# ╠═420e7070-f614-11ea-155a-c18fc549f2cd
# ╟─9aa70686-f614-11ea-2767-39ec8e428137
# ╟─2e082e5c-f616-11ea-1e64-c55552c523df
# ╠═a41686d8-f612-11ea-0b06-e7ca3f9dfaeb
# ╟─7ba8de66-f61d-11ea-1a1c-c5e3e7b0ef54
# ╠═c91c64d8-f613-11ea-01bd-c55b35610e15
# ╟─53036722-f615-11ea-1526-59fb62500060
# ╟─68611d20-f616-11ea-1a48-ff9b9b125b24
# ╟─b5967680-f61b-11ea-29ff-e151fd817baf
# ╠═51813362-f619-11ea-16f8-2101534d2881
# ╟─08da756c-f51d-11ea-2167-61055a2ba344
# ╟─ead9e534-f620-11ea-18c6-b356e37fe51a
# ╟─030c9e10-f61e-11ea-2080-1325c8e8cd3b
# ╟─135fff12-f69f-11ea-3f00-45aa2f5c340b
# ╟─30f297be-f6a3-11ea-0509-6db3c3648a8b
# ╟─99c902ca-f52a-11ea-29c7-13394ff733c5
# ╟─b2e0752c-f52a-11ea-0a58-df9764cfb38c
