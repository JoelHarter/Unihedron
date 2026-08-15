module Unihedron

using StaticArrays
using LinearAlgebra
using QHull
using GLMakie
using GLMakie.GeometryBasics

include("types.jl")
include("geometrytools.jl")
include("convexhull.jl")
include("prisms.jl")
include("platonic.jl")
include("archimedean.jl")
include("kepler_poinsot.jl")
include("catalan.jl")
include("cookson.jl")
include("operations.jl")
include("johnson.jl")
include("visualization.jl")

# Core Types
export Pt2, Pt3, Points, Polyhedron, Hedron, FaceIndexList

# Geometry Tools
export Polygon2, center_of_mass, centroid, face_normal, dual
export isBordering, isCoplanar, isSimilar, isCongruent
export backwards, increment
export sew_coplanar_faces, merge_coplanar_faces, sew_faces

# Convex Hull
export convex_hull

# Visualization & Display (Makie)
export display_polygon, display_polygon!, plot_polygon, plot_polygon!
export display_polyhedron, display_polyhedron!, plot_polyhedron, plot_polyhedron!
export viz

# Prisms, Antiprisms, Pyramids, Bipyramids, Trapezohedra
export prism, antiprism, pyramid, bipyramid, dipyramid
export trapezohedron, gyrobipyramid, antidipyramid, deltohedron

# Constructive Operations & Caps
export cupola, rotunda, pentagonal_rotunda
export elongate, gyroelongate, augment, diminish, gyrate

# Platonic Solids
export platonic
export tetrahedron, cube, octahedron, icosahedron, dodecahedron

# Archimedean Solids
export archimedean
export truncated_tetrahedron, cuboctahedron, truncated_cube, truncated_octahedron
export rhombicuboctahedron, truncated_cuboctahedron, snub_cube
export icosidodecahedron, truncated_icosahedron, truncated_dodecahedron
export rhombicosidodecahedron, truncated_icosidodecahedron, snub_dodecahedron

# Kepler-Poinsot Solids
export kepler_poinsot
export great_dodecahedron, small_stellated_dodecahedron
export great_stellated_dodecahedron, great_icosahedron

# Catalan Solids
export catalan
export triakis_tetrahedron, rhombic_dodecahedron, triakis_octahedron, tetrakis_hexahedron
export deltoidal_icositetrahedron, disdyakis_dodecahedron, pentagonal_icositetrahedron
export rhombic_triacontahedron, pentakis_dodecahedron, triakis_icosahedron
export deltoidal_hexecontahedron, disdyakis_triacontahedron, pentagonal_hexecontahedron

# Cookson Solids
export cookson
export cooksonian_rhombic_dodecahedron, cooksonian_rhombic_triacontahedron
export cooksonian_deltoidal_icositetrahedron, cooksonian_deltoidal_hexecontahedron
export cooksonian_pentagonal_icositetrahedron, cooksonian_pentagonal_hexecontahedron

# Johnson Solids
export johnson, johnson_name, johnson_names
export square_pyramid, pentagonal_pyramid, triangular_cupola, square_cupola, pentagonal_cupola
export gyrobifastigium, snub_disphenoid, snub_square_antiprism, sphenocorona
export sphenomegacorona, hebesphenomegacorona, disphenocingulum, bilunabirotunda
export triangular_hebesphenorotunda

end # module Unihedron
