include("unihedron.jl")
using .Unihedron

## Quick Test / Demo
v = Points((0.,0,0), [1,0,0], [1,1,0], [0,1,0], [0,0,1])
f = [[1,2,3,4], [1,2,5], [2,3,5], [3,4,5], [4,1,5]]
P = Polyhedron(v, f)