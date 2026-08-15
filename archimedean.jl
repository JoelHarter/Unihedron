"""
Archimedean solid generators returning `Polyhedron` objects.
All 13 semi-regular convex polyhedra with regular polygon faces and symmetric vertices.
"""

# Helper permutation & sign utilities
function _even_perms(v)
    return [(v[1], v[2], v[3]), (v[2], v[3], v[1]), (v[3], v[1], v[2])]
end

function _all_perms(v)
    return [
        (v[1], v[2], v[3]), (v[1], v[3], v[2]),
        (v[2], v[1], v[3]), (v[2], v[3], v[1]),
        (v[3], v[1], v[2]), (v[3], v[2], v[1])
    ]
end

function _sign_vars(v)
    res = NTuple{3, Float64}[]
    s1_vals = v[1] == 0 ? (1.0,) : (1.0, -1.0)
    s2_vals = v[2] == 0 ? (1.0,) : (1.0, -1.0)
    s3_vals = v[3] == 0 ? (1.0,) : (1.0, -1.0)
    for s1 in s1_vals
        for s2 in s2_vals
            for s3 in s3_vals
                push!(res, (s1 * v[1], s2 * v[2], s3 * v[3]))
            end
        end
    end
    return res
end

function _gen_pts(base_tuples; perm_func=_even_perms)
    pts = Set{Pt3{Float64}}()
    for base in base_tuples
        for p in perm_func(base)
            for s in _sign_vars(p)
                push!(pts, Pt3{Float64}(s...))
            end
        end
    end
    return collect(pts)
end

"""
    truncated_tetrahedron()

Constructs a truncated tetrahedron (12 vertices, 8 faces: 4 triangles, 4 hexagons).
"""
function truncated_tetrahedron()
    pts = Pt3{Float64}[]
    for p in _all_perms((3.0, 1.0, 1.0))
        for s in _sign_vars(p)
            if s[1] * s[2] * s[3] > 0
                push!(pts, Pt3{Float64}(s...))
            end
        end
    end
    return convex_hull(unique(pts); merge_coplanar=true)
end

"""
    cuboctahedron()

Constructs a cuboctahedron (12 vertices, 14 faces: 8 triangles, 6 squares).
"""
function cuboctahedron()
    pts = _gen_pts([(1.0, 1.0, 0.0)]; perm_func=_all_perms)
    return convex_hull(pts; merge_coplanar=true)
end

"""
    truncated_cube()

Constructs a truncated cube (24 vertices, 14 faces: 8 triangles, 6 octagons).
"""
function truncated_cube()
    ξ = sqrt(2.0) - 1.0
    pts = _gen_pts([(ξ, 1.0, 1.0)]; perm_func=_all_perms)
    return convex_hull(pts; merge_coplanar=true)
end

"""
    truncated_octahedron()

Constructs a truncated octahedron (24 vertices, 14 faces: 6 squares, 8 hexagons).
"""
function truncated_octahedron()
    pts = _gen_pts([(0.0, 1.0, 2.0)]; perm_func=_all_perms)
    return convex_hull(pts; merge_coplanar=true)
end

"""
    rhombicuboctahedron()

Constructs a rhombicuboctahedron / small rhombicuboctahedron (24 vertices, 26 faces: 8 triangles, 18 squares).
"""
function rhombicuboctahedron()
    ξ = 1.0 + sqrt(2.0)
    pts = _gen_pts([(1.0, 1.0, ξ)]; perm_func=_all_perms)
    return convex_hull(pts; merge_coplanar=true)
end

"""
    truncated_cuboctahedron()

Constructs a truncated cuboctahedron / great rhombicuboctahedron (48 vertices, 26 faces: 12 squares, 8 hexagons, 6 octagons).
"""
function truncated_cuboctahedron()
    ξ = 1.0 + sqrt(2.0)
    η = 1.0 + 2.0 * sqrt(2.0)
    pts = _gen_pts([(1.0, ξ, η)]; perm_func=_all_perms)
    return convex_hull(pts; merge_coplanar=true)
end

"""
    snub_cube()

Constructs a snub cube / snub hexahedron (24 vertices, 38 faces: 32 triangles, 6 squares).
"""
function snub_cube()
    # Tribonacci constant
    ξ = (1.0 + (19.0 + 3.0 * sqrt(33.0))^(1/3) + (19.0 - 3.0 * sqrt(33.0))^(1/3)) / 3.0
    pts = Pt3{Float64}[]
    base = (1.0, 1.0 / ξ, ξ)
    for p in [(base[1], base[2], base[3]), (base[2], base[3], base[1]), (base[3], base[1], base[2])]
        for s in _sign_vars(p)
            if count(x -> x < 0, s) % 2 == 0
                push!(pts, Pt3{Float64}(s...))
            end
        end
    end
    for p in [(base[1], base[3], base[2]), (base[2], base[1], base[3]), (base[3], base[2], base[1])]
        for s in _sign_vars(p)
            if count(x -> x < 0, s) % 2 == 1
                push!(pts, Pt3{Float64}(s...))
            end
        end
    end
    return convex_hull(unique(pts); merge_coplanar=true)
end

"""
    icosidodecahedron()

Constructs an icosidodecahedron (30 vertices, 32 faces: 20 triangles, 12 pentagons).
"""
function icosidodecahedron()
    ϕ = (1.0 + sqrt(5.0)) / 2.0
    pts = _gen_pts([(0.0, 0.0, 2.0 * ϕ), (1.0, ϕ, ϕ^2)]; perm_func=_even_perms)
    return convex_hull(pts; merge_coplanar=true)
end

"""
    truncated_icosahedron()

Constructs a truncated icosahedron (60 vertices, 32 faces: 12 pentagons, 20 hexagons).
"""
function truncated_icosahedron()
    ϕ = (1.0 + sqrt(5.0)) / 2.0
    pts = _gen_pts([
        (0.0, 1.0, 3.0 * ϕ),
        (2.0, 1.0 + 2.0 * ϕ, ϕ),
        (1.0, 2.0 + ϕ, 2.0 * ϕ)
    ]; perm_func=_even_perms)
    return convex_hull(pts; merge_coplanar=true)
end

"""
    truncated_dodecahedron()

Constructs a truncated dodecahedron (60 vertices, 32 faces: 20 triangles, 12 decagons).
"""
function truncated_dodecahedron()
    ϕ = (1.0 + sqrt(5.0)) / 2.0
    pts = _gen_pts([
        (0.0, 1.0 / ϕ, 2.0 + ϕ),
        (1.0 / ϕ, ϕ, 2.0 * ϕ),
        (ϕ, 2.0, ϕ + 1.0)
    ]; perm_func=_even_perms)
    return convex_hull(pts; merge_coplanar=true)
end

"""
    rhombicosidodecahedron()

Constructs a rhombicosidodecahedron / small rhombicosidodecahedron (60 vertices, 62 faces: 20 triangles, 30 squares, 12 pentagons).
"""
function rhombicosidodecahedron()
    ϕ = (1.0 + sqrt(5.0)) / 2.0
    pts = _gen_pts([
        (1.0, 1.0, ϕ^3),
        (ϕ^2, ϕ, 2.0 * ϕ),
        (2.0 + ϕ, 0.0, ϕ^2)
    ]; perm_func=_even_perms)
    return convex_hull(pts; merge_coplanar=true)
end

"""
    truncated_icosidodecahedron()

Constructs a truncated icosidodecahedron / great rhombicosidodecahedron (120 vertices, 62 faces: 30 squares, 20 hexagons, 12 decagons).
"""
function truncated_icosidodecahedron()
    ϕ = (1.0 + sqrt(5.0)) / 2.0
    pts = _gen_pts([
        (1.0 / ϕ, 1.0 / ϕ, 3.0 + ϕ),
        (2.0 / ϕ, ϕ, 1.0 + 2.0 * ϕ),
        (1.0 / ϕ, ϕ^2, 3.0 * ϕ - 1.0),
        (2.0 * ϕ - 1.0, 2.0, 2.0 + ϕ),
        (ϕ, 3.0, 2.0 * ϕ)
    ]; perm_func=_even_perms)
    return convex_hull(pts; merge_coplanar=true)
end

"""
    snub_dodecahedron()

Constructs a snub dodecahedron / snub icosidodecahedron (60 vertices, 92 faces: 80 triangles, 12 pentagons).
"""
function snub_dodecahedron()
    ϕ = (1.0 + sqrt(5.0)) / 2.0
    # Solve xi^3 - 2xi - phi = 0
    ξ = 1.7155614996973678
    for _ in 1:20
        f = ξ^3 - 2 * ξ - ϕ
        df = 3 * ξ^2 - 2
        ξ -= f / df
    end
    α = ξ - 1.0 / ξ
    β = ξ * ϕ + ϕ^2 + ϕ / ξ

    sign_tuples = [(1.0, 1.0, 1.0), (1.0, -1.0, -1.0), (-1.0, 1.0, -1.0), (-1.0, -1.0, 1.0)]
    bases = [
        (2 * α, 2.0, 2 * β),
        (α + β / ϕ + ϕ, -α * ϕ + β + 1.0 / ϕ, α / ϕ + β * ϕ - 1.0),
        (-α / ϕ + β * ϕ + 1.0, -α + β / ϕ - ϕ, α * ϕ + β - 1.0 / ϕ),
        (-α / ϕ + β * ϕ - 1.0, α - β / ϕ - ϕ, α * ϕ + β + 1.0 / ϕ),
        (α + β / ϕ - ϕ, α * ϕ - β + 1.0 / ϕ, α / ϕ + β * ϕ + 1.0)
    ]

    pts = Pt3{Float64}[]
    for base in bases
        for p in _even_perms(base)
            for (s1, s2, s3) in sign_tuples
                push!(pts, Pt3{Float64}(s1 * p[1], s2 * p[2], s3 * p[3]))
            end
        end
    end
    return convex_hull(unique(pts); merge_coplanar=true)
end

const ARCHIMEDEAN_SOLID_MAP = Dict{Symbol, Function}(
    :truncated_tetrahedron => truncated_tetrahedron,
    :cuboctahedron => cuboctahedron,
    :truncated_cube => truncated_cube,
    :truncated_octahedron => truncated_octahedron,
    :rhombicuboctahedron => rhombicuboctahedron,
    :truncated_cuboctahedron => truncated_cuboctahedron,
    :snub_cube => snub_cube,
    :icosidodecahedron => icosidodecahedron,
    :truncated_icosahedron => truncated_icosahedron,
    :truncated_dodecahedron => truncated_dodecahedron,
    :rhombicosidodecahedron => rhombicosidodecahedron,
    :truncated_icosidodecahedron => truncated_icosidodecahedron,
    :snub_dodecahedron => snub_dodecahedron
)

const ARCHIMEDEAN_SOLID_ORDER = [
    :truncated_tetrahedron,
    :cuboctahedron,
    :truncated_cube,
    :truncated_octahedron,
    :rhombicuboctahedron,
    :truncated_cuboctahedron,
    :snub_cube,
    :icosidodecahedron,
    :truncated_icosahedron,
    :truncated_dodecahedron,
    :rhombicosidodecahedron,
    :truncated_icosidodecahedron,
    :snub_dodecahedron
]

"""
    archimedean(name::Symbol)
    archimedean(index::Integer)

Access any of the 13 Archimedean solids by name symbol or index (1-13).
"""
function archimedean(name::Symbol)
    haskey(ARCHIMEDEAN_SOLID_MAP, name) || error("Unknown Archimedean solid: $name. Available: $(keys(ARCHIMEDEAN_SOLID_MAP))")
    return ARCHIMEDEAN_SOLID_MAP[name]()
end

function archimedean(index::Integer)
    1 <= index <= 13 || error("Archimedean solid index must be between 1 and 13.")
    return archimedean(ARCHIMEDEAN_SOLID_ORDER[index])
end
