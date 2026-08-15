"""
Catalan solid generators returning `Polyhedron` objects.
All 13 Catalan solids (duals of the Archimedean solids), generated dynamically via `dual()`.
"""

"""
    triakis_tetrahedron()

Constructs a triakis tetrahedron (8 vertices, 12 isosceles triangle faces).
Dual of the truncated tetrahedron.
"""
triakis_tetrahedron() = dual(truncated_tetrahedron())

"""
    rhombic_dodecahedron()

Constructs a rhombic dodecahedron (14 vertices, 12 rhombus faces).
Dual of the cuboctahedron.
"""
rhombic_dodecahedron() = dual(cuboctahedron())

"""
    triakis_octahedron()

Constructs a triakis octahedron (14 vertices, 24 isosceles triangle faces).
Dual of the truncated cube.
"""
triakis_octahedron() = dual(truncated_cube())

"""
    tetrakis_hexahedron()

Constructs a tetrakis hexahedron (14 vertices, 24 isosceles triangle faces).
Dual of the truncated octahedron.
"""
tetrakis_hexahedron() = dual(truncated_octahedron())

"""
    deltoidal_icositetrahedron()

Constructs a deltoidal icositetrahedron / trapezoidal icositetrahedron (26 vertices, 24 kite faces).
Dual of the rhombicuboctahedron.
"""
deltoidal_icositetrahedron() = dual(rhombicuboctahedron())

"""
    disdyakis_dodecahedron()

Constructs a disdyakis dodecahedron / hexakis octahedron (26 vertices, 48 scalene triangle faces).
Dual of the truncated cuboctahedron.
"""
disdyakis_dodecahedron() = dual(truncated_cuboctahedron())

"""
    pentagonal_icositetrahedron()

Constructs a pentagonal icositetrahedron (38 vertices, 24 chiral pentagonal faces).
Dual of the snub cube.
"""
pentagonal_icositetrahedron() = dual(snub_cube())

"""
    rhombic_triacontahedron()

Constructs a rhombic triacontahedron (32 vertices, 30 rhombus faces).
Dual of the icosidodecahedron.
"""
rhombic_triacontahedron() = dual(icosidodecahedron())

"""
    pentakis_dodecahedron()

Constructs a pentakis dodecahedron (32 vertices, 60 isosceles triangle faces).
Dual of the truncated icosahedron.
"""
pentakis_dodecahedron() = dual(truncated_icosahedron())

"""
    triakis_icosahedron()

Constructs a triakis icosahedron (32 vertices, 60 isosceles triangle faces).
Dual of the truncated dodecahedron.
"""
triakis_icosahedron() = dual(truncated_dodecahedron())

"""
    deltoidal_hexecontahedron()

Constructs a deltoidal hexecontahedron / trapezoidal hexecontahedron (62 vertices, 60 kite faces).
Dual of the rhombicosidodecahedron.
"""
deltoidal_hexecontahedron() = dual(rhombicosidodecahedron())

"""
    disdyakis_triacontahedron()

Constructs a disdyakis triacontahedron / hexakis icosahedron (62 vertices, 120 scalene triangle faces).
Dual of the truncated icosidodecahedron.
"""
disdyakis_triacontahedron() = dual(truncated_icosidodecahedron())

"""
    pentagonal_hexecontahedron()

Constructs a pentagonal hexecontahedron (92 vertices, 60 chiral pentagonal faces).
Dual of the snub dodecahedron.
"""
pentagonal_hexecontahedron() = dual(snub_dodecahedron())

const CATALAN_SOLID_MAP = Dict{Symbol, Function}(
    :triakis_tetrahedron => triakis_tetrahedron,
    :rhombic_dodecahedron => rhombic_dodecahedron,
    :triakis_octahedron => triakis_octahedron,
    :tetrakis_hexahedron => tetrakis_hexahedron,
    :deltoidal_icositetrahedron => deltoidal_icositetrahedron,
    :disdyakis_dodecahedron => disdyakis_dodecahedron,
    :pentagonal_icositetrahedron => pentagonal_icositetrahedron,
    :rhombic_triacontahedron => rhombic_triacontahedron,
    :pentakis_dodecahedron => pentakis_dodecahedron,
    :triakis_icosahedron => triakis_icosahedron,
    :deltoidal_hexecontahedron => deltoidal_hexecontahedron,
    :disdyakis_triacontahedron => disdyakis_triacontahedron,
    :pentagonal_hexecontahedron => pentagonal_hexecontahedron
)

const CATALAN_SOLID_ORDER = [
    :triakis_tetrahedron,
    :rhombic_dodecahedron,
    :triakis_octahedron,
    :tetrakis_hexahedron,
    :deltoidal_icositetrahedron,
    :disdyakis_dodecahedron,
    :pentagonal_icositetrahedron,
    :rhombic_triacontahedron,
    :pentakis_dodecahedron,
    :triakis_icosahedron,
    :deltoidal_hexecontahedron,
    :disdyakis_triacontahedron,
    :pentagonal_hexecontahedron
]

"""
    catalan(name::Symbol)
    catalan(index::Integer)

Access any of the 13 Catalan solids by name symbol or index (1-13).
"""
function catalan(name::Symbol)
    haskey(CATALAN_SOLID_MAP, name) || error("Unknown Catalan solid: $name. Available: $(keys(CATALAN_SOLID_MAP))")
    return CATALAN_SOLID_MAP[name]()
end

function catalan(index::Integer)
    1 <= index <= 13 || error("Catalan solid index must be between 1 and 13.")
    return catalan(CATALAN_SOLID_ORDER[index])
end
