module Unihedron

using StaticArrays
using LinearAlgebra
using QHull
using GLMakie
using GLMakie.GeometryBasics
using HDF5
using JSON3

include("types.jl")
include("geometrytools.jl")
include("polygons.jl")
include("convexhull.jl")
include("prisms.jl")
include("platonic.jl")
include("archimedean.jl")
include("keplerpoinsot.jl")
include("catalan.jl")
include("cookson.jl")
include("operations.jl")
include("johnson.jl")
include("geodesic.jl")
include("visualization.jl")
include("io.jl")
include("print.jl")

# Core Types
export Pt2, Pt3, Points, Polyhedron, Hedron, FaceIndexList

# Geometry Tools & Congruence Classification
export Polygon2, center_of_mass, centroid, face_normal, dual
export isBordering, isCoplanar, isSimilar, isCongruent
export backwards, increment
export sew_coplanar_faces, merge_coplanar_faces, sew_faces
export classify_faces, congruent_face_types, face_types, unique_face_polygons, face_type_counts
export classify_faces_with_handedness, is_2d_polygon_achiral, is_achiral_polygon, is_achiral, project_face_outward_2d

# 2D Polygons, Polygrams, Stars & Parametric Shapes
export regular_polygon, polygon
export equilateral_triangle, square_polygon, regular_pentagon, regular_hexagon
export regular_heptagon, regular_octagon, regular_nonagon, regular_decagon
export regular_hendecagon, regular_dodecagon
export polygram, star_polygon, star
export pentagram, hexagram, heptagram, octagram, decagram
export rectangle, rhombus, trapezoid, parallelogram, kite_polygon, ellipse_polygon, reuleaux_polygon

# Convex Hull
export convex_hull

# File I/O & Export
export save_polyhedron, load_polyhedron
export save_off, load_off
export save_obj, load_obj
export save_json, load_json
export save_hdf5, load_hdf5
export save_stl
export save_polygon, load_polygon2d, load_polygon3d
export export_database_hdf5
export DEFAULT_POLYHEDRON_FORMAT

# Printing & Image Rendering (PNG, JPG, SVG, PDF)
export print_polyhedron, print_polygon, print_image, print_gallery
export save_polyhedron_image, save_polygon_image, save_image

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

# Cookson Solids (H1 - H8) & Excluded Spherical Solids
export cookson, cookson_name, cookson_names, cookson_info
export excluded_cookson, excluded_cookson_name, excluded_cookson_names
export gyrotrapezotrigonal_octasphere, gyrotrapezotrigonal_icosasphere
export studded_octahedron, studded_octasphere
export studded_icosahedron, studded_icosasphere
export studded_cuboctahedron, bistudded_cuboctasphere, bi_studded_cuboctasphere
export studded_rhombic_triacontasphere, bistudded_rhombic_triacontasphere, bi_studded_rhombic_triacontasphere
export gyrobitrigonal_octasphere, gyrobitrigonal_icosasphere
export studded_hexasphere, studded_dodecasphere, studded_rhombic_dodecasphere, studded_cuboctasphere, studded_dodecasphere_ii
export studded_triacontasphere, studded_rhombic_triacontasphere_excluded
export bistudded_dodecasphere, bi_studded_dodecasphere
export bistudded_triacontasphere, bi_studded_triacontasphere

# Johnson Solids
export johnson, johnson_name, johnson_names
export square_pyramid, pentagonal_pyramid, triangular_cupola, square_cupola, pentagonal_cupola
export gyrobifastigium, snub_disphenoid, snub_square_antiprism, sphenocorona
export sphenomegacorona, hebesphenomegacorona, disphenocingulum, bilunabirotunda
export triangular_hebesphenorotunda

# Geodesic Spheres & Buckyballs / Fullerenes / Honeyballs
export buckyball, fullerene, goldberg_polyhedron
export geodesic_sphere, geodesic_icosahedron, honeyball, honeycomb_ball

end # module Unihedron
