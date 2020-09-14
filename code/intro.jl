
### Type inference
x = [10, "foo", false]
y = [1, 2, 3]
z = [true, false, true]
w = [1.0, 2.0, 3.0]
u = [1.0, 2, 3]
v = [0, 1, true]
r = [π, 2, 3]
s = [0.0, 1.0, false]
t = [1.0, nothing, 3.0]
q = [1.0, missing, 3.0]
p = [1.0, -Inf, 3.0]
a = [1.0, NaN, 3.0]

### Abstract and concrete types
Int <: Number
Int <: Float64
Real <: Number
(Array{T, 1} where T) == (Vector{T} where T)

supertype(Number)
subtypes(Number)
subtypes(Real)
subtypes(AbstractFloat)

abstract type Person end

struct Professor<:Person
    students::Vector{String}
end

Professor <: Person
Person <: Professor
Thomas = Professor(["Matthias", "Maurice"])
typeof(Thomas)
Thomas

### Multiple dispatch
function sum(arr::Vector{Int})
  println("sum over ints...")
  val = 0
  for i in arr
    val += i
  end
  val
end

function sum(arr::Vector{Float64})
  println("sum over floats...")
  val = 0.0
  for i in arr
    val += i
  end
  val
end

sum

my_arr = [1, 2, 3, 4]

sum(my_arr)

sum([1.0, 2.0, 3.0, 4.0])

### Metaprogramming
ex1 = :(1 + b)
ex2 = quote
    1 + b
end
b = 1
eval(ex1)
eval(ex2)
typeof(ex1)

ex = :(if b==1 print("hi") end)
eval(ex)

# change the expression and re-evaluate
P = quote
   a = 2
   b = 3
   c = 4
   d = 5
   e = sum([a,b,c,d])
end
eval(P) # sum

P.args
P.args[end] = quote prod([a,b,c,d]) end
eval(P) # product
