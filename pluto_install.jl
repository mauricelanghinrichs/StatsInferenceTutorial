### A Pluto.jl notebook ###
# v0.11.14

using Markdown
using InteractiveUtils

# ╔═╡ cbed2706-f5ff-11ea-3f13-d1bafad9f4bc
using Pkg

# ╔═╡ a83e9a60-f5ff-11ea-03f2-97f7da5cb845
md"""
## Before we start
"""

# ╔═╡ ba1d76c0-f5ff-11ea-3d06-31a4ecf262c0
md"""
_Tutorial requirements_ (the complete process might take ~30 min.)
1. [Julia installation](https://julialang.org/downloads/)
2. [Atom and Juno (the Julia editor)](http://docs.junolab.org/latest/man/installation/)
3. Julia packages listed below:
"""

# ╔═╡ c4405604-f5ff-11ea-244c-cf9751fccd9d
Text(sprint(io -> Pkg.status(io=io)))

# ╔═╡ dcc9c728-f5ff-11ea-2f76-d773c955b8c2
md"
_How to install and precompile Julia packages_
1. Start Julia in the terminal (Applications -> Julia-1.5)
2. Enter “]” to get into Julia package mode (pkg>)
3. Install a package X by writing “add X” (repeat for each package)
4. View all installed packages with “status”
5. Precompile all packages with “precompile”
6. Leave the package mode by pressing backspace (julia>)
7. Import a package by “using X” for a package X
"

# ╔═╡ Cell order:
# ╟─cbed2706-f5ff-11ea-3f13-d1bafad9f4bc
# ╟─a83e9a60-f5ff-11ea-03f2-97f7da5cb845
# ╟─ba1d76c0-f5ff-11ea-3d06-31a4ecf262c0
# ╟─c4405604-f5ff-11ea-244c-cf9751fccd9d
# ╟─dcc9c728-f5ff-11ea-2f76-d773c955b8c2
