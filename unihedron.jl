module Unihedron

using StaticArrays
using LinearAlgebra
using QHull

include("types.jl")
include("geometrytools.jl")
include("platonic.jl")
include("convexhull.jl")

# Core Types
export Pt2, Pt3, Points, Polyhedron, Hedron, FaceIndexList

# Geometry Tools
export Polygon2, center_of_mass, centroid, face_normal
export isBordering, isCoplanar, isSimilar, isCongruent
export backwards, increment

# Convex Hull
export convex_hull

# Platonic Solids
export tetrahedron, cube, octahedron, icosahedron, dodecahedron

end # module Unihedron
