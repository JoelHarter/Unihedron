"""
Platonic solid generators returning `Polyhedron` objects.
"""

"""
    tetrahedron()

Constructs a regular tetrahedron (4 vertices, 4 triangular faces).
"""
function tetrahedron()
    v = [
        Pt3{Float64}(1.0, 1.0, 1.0),
        Pt3{Float64}(1.0, -1.0, -1.0),
        Pt3{Float64}(-1.0, 1.0, -1.0),
        Pt3{Float64}(-1.0, -1.0, 1.0)
    ]
    f = [
        [1, 2, 3],
        [1, 3, 4],
        [1, 4, 2],
        [2, 4, 3]
    ]
    return Polyhedron(v, f)
end

"""
    cube()

Constructs a regular cube / hexahedron (8 vertices, 6 quadrilateral faces).
"""
function cube()
    v = [
        Pt3{Float64}(-1.0, -1.0, -1.0),
        Pt3{Float64}( 1.0, -1.0, -1.0),
        Pt3{Float64}( 1.0,  1.0, -1.0),
        Pt3{Float64}(-1.0,  1.0, -1.0),
        Pt3{Float64}(-1.0, -1.0,  1.0),
        Pt3{Float64}( 1.0, -1.0,  1.0),
        Pt3{Float64}( 1.0,  1.0,  1.0),
        Pt3{Float64}(-1.0,  1.0,  1.0)
    ]
    f = [
        [1, 2, 3, 4],
        [5, 8, 7, 6],
        [1, 5, 6, 2],
        [2, 6, 7, 3],
        [3, 7, 8, 4],
        [4, 8, 5, 1]
    ]
    return Polyhedron(v, f)
end

"""
    octahedron()

Constructs a regular octahedron (6 vertices, 8 triangular faces).
"""
function octahedron()
    v = [
        Pt3{Float64}( 1.0,  0.0,  0.0),
        Pt3{Float64}(-1.0,  0.0,  0.0),
        Pt3{Float64}( 0.0,  1.0,  0.0),
        Pt3{Float64}( 0.0, -1.0,  0.0),
        Pt3{Float64}( 0.0,  0.0,  1.0),
        Pt3{Float64}( 0.0,  0.0, -1.0)
    ]
    f = [
        [1, 3, 5], [3, 2, 5], [2, 4, 5], [4, 1, 5],
        [3, 1, 6], [2, 3, 6], [4, 2, 6], [1, 4, 6]
    ]
    return Polyhedron(v, f)
end

"""
    icosahedron()

Constructs a regular icosahedron (12 vertices, 20 triangular faces).
"""
function icosahedron()
    ϕ = (1.0 + sqrt(5.0)) / 2.0
    v = [
        Pt3{Float64}(-1.0,  ϕ, 0.0), Pt3{Float64}( 1.0,  ϕ, 0.0),
        Pt3{Float64}(-1.0, -ϕ, 0.0), Pt3{Float64}( 1.0, -ϕ, 0.0),
        Pt3{Float64}(0.0, -1.0,  ϕ), Pt3{Float64}(0.0,  1.0,  ϕ),
        Pt3{Float64}(0.0, -1.0, -ϕ), Pt3{Float64}(0.0,  1.0, -ϕ),
        Pt3{Float64}( ϕ, 0.0, -1.0), Pt3{Float64}( ϕ, 0.0,  1.0),
        Pt3{Float64}(-ϕ, 0.0, -1.0), Pt3{Float64}(-ϕ, 0.0,  1.0)
    ]
    f = [
        [1, 12, 6], [1, 6, 2], [1, 2, 8], [1, 8, 11], [1, 11, 12],
        [2, 6, 10], [6, 12, 5], [12, 11, 3], [11, 8, 7], [8, 2, 9],
        [4, 10, 5], [4, 5, 3], [4, 3, 7], [4, 7, 9], [4, 9, 10],
        [5, 10, 6], [3, 5, 12], [7, 3, 11], [9, 7, 8], [10, 9, 2]
    ]
    return Polyhedron(v, f)
end

"""
    dodecahedron()

Constructs a regular dodecahedron (20 vertices, 12 pentagonal faces).
"""
function dodecahedron()
    ico = icosahedron()
    d = dual(ico; polar=true)
    # Scale to radius 1.0 or natural edge
    return d
end

const PLATONIC_SOLID_MAP = Dict{Symbol, Function}(
    :tetrahedron => tetrahedron,
    :cube => cube,
    :octahedron => octahedron,
    :icosahedron => icosahedron,
    :dodecahedron => dodecahedron
)

const PLATONIC_SOLID_ORDER = [
    :tetrahedron,
    :cube,
    :octahedron,
    :icosahedron,
    :dodecahedron
]

"""
    platonic(name::Symbol)
    platonic(index::Integer)

Access any of the 5 Platonic solids by name symbol or index (1-5).
"""
function platonic(name::Symbol)
    haskey(PLATONIC_SOLID_MAP, name) || error("Unknown Platonic solid: $name. Available: $(keys(PLATONIC_SOLID_MAP))")
    return PLATONIC_SOLID_MAP[name]()
end

function platonic(index::Integer)
    1 <= index <= 5 || error("Platonic solid index must be between 1 and 5.")
    return platonic(PLATONIC_SOLID_ORDER[index])
end

