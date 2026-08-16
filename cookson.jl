# The Cookson Solids (Topological Regimes)
# Discovered by Arthur J Cookson in 2026.
#
# A Cookson Solid is a Topological Regime—a continuous sliding family of spherical polyhedra
# satisfying the Core Axioms (The Sieve):
# 1. The Spherical Anchor: Every vertex lies exactly on the surface of a single sphere.
# 2. The Two-Polygon Limit: Faces consist of at most two distinct geometric types (chiral enantiomorphs count as one).
# 3. Strict Topological Graph: The vertex-edge-face connectivity remains constant.
# 4. Forced Simplification: Coplanar faces merge; coincident vertices merge.
# 5. No Self-Intersection: Faces and edges may not cross through one another.
# 6. Taxonomic Exclusion (The Claim Rule): Excludes regimes claimed by classical sets or infinite series.

using StaticArrays
using LinearAlgebra

# Helper to order face vertices cyclically
function _order_face_perimeter(verts::AbstractVector{Pt3{T}}, face::AbstractVector{Int}) where T
    length(face) <= 3 && return face
    pts = [verts[k] for k in face]
    center = sum(pts) / length(pts)
    n = face_normal(pts)
    if norm(n) < 1e-8
        return face
    end
    u = normalize(pts[1] - center)
    v = normalize(n × u)
    angles = [atan((p - center) ⋅ v, (p - center) ⋅ u) for p in pts]
    p = sortperm(angles)
    return face[p]
end

function _clean_face_order(P::Polyhedron)
    new_faces = [_order_face_perimeter(P.v, f) for f in P.f]
    return Polyhedron(P.v, new_faces)
end

"""
    cookson(P::Polyhedron; radius::Real=1.0)

Constructs the canonical convex Cookson solid corresponding to a polyhedron `P` by projecting its
vertices onto a sphere of the given `radius`, and subdividing any resulting non-planar faces along
internal creases (convex hull) to restore strict three-dimensional planarity.
"""
function cookson(P::Polyhedron; radius::Real=1.0)
    v_sph = Pt3{Float64}[radius * (v / norm(v)) for v in P.v]
    return convex_hull(v_sph; merge_coplanar=true)
end

# ============================================================================
# The 6 Convex Cookson Regimes (C1 - C6) - Art's Discoveries
# ============================================================================

"""
    trigonal_octasphere(; radius::Real=1.0)
    cooksonian_rhombic_dodecahedron(; radius::Real=1.0)

Constructs Cookson solid C1: Trigonal Octasphere (V=14, F=24).
- Polygon Root: Trigonal | Symmetry: Octasphere | Parent Catalan: Rhombic Dodecahedron
- Derivation: Convex projection of the Rhombic Dodecahedron.
"""
function trigonal_octasphere(; radius::Real=1.0)
    return cookson(rhombic_dodecahedron(); radius=radius)
end
const cooksonian_rhombic_dodecahedron = trigonal_octasphere

"""
    trigonal_icosasphere(; radius::Real=1.0)
    cooksonian_rhombic_triacontahedron(; radius::Real=1.0)

Constructs Cookson solid C2: Trigonal Icosasphere (V=32, F=60).
- Polygon Root: Trigonal | Symmetry: Icosasphere | Parent Catalan: Rhombic Triacontahedron
- Derivation: Convex projection of the Rhombic Triacontahedron.
"""
function trigonal_icosasphere(; radius::Real=1.0)
    return cookson(rhombic_triacontahedron(); radius=radius)
end
const cooksonian_rhombic_triacontahedron = trigonal_icosasphere

"""
    bitrigonal_octasphere(; radius::Real=1.0)
    cooksonian_deltoidal_icositetrahedron(; radius::Real=1.0)

Constructs Cookson solid C3: Bitrigonal Octasphere (V=26, F=48).
- Polygon Root: Bitrigonal | Symmetry: Octasphere | Parent Catalan: Deltoidal Icositetrahedron
- Derivation: Convex projection of the Deltoidal Icositetrahedron.
"""
function bitrigonal_octasphere(; radius::Real=1.0)
    return cookson(deltoidal_icositetrahedron(); radius=radius)
end
const cooksonian_deltoidal_icositetrahedron = bitrigonal_octasphere

"""
    bitrigonal_icosasphere(; radius::Real=1.0)
    cooksonian_deltoidal_hexecontahedron(; radius::Real=1.0)

Constructs Cookson solid C4: Bitrigonal Icosasphere (V=62, F=120).
- Polygon Root: Bitrigonal | Symmetry: Icosasphere | Parent Catalan: Deltoidal Hexecontahedron
- Derivation: Convex projection of the Deltoidal Hexecontahedron.
"""
function bitrigonal_icosasphere(; radius::Real=1.0)
    return cookson(deltoidal_hexecontahedron(); radius=radius)
end
const cooksonian_deltoidal_hexecontahedron = bitrigonal_icosasphere

"""
    gyrotrapezotrigonal_octasphere(; radius::Real=1.0)
    cooksonian_pentagonal_icositetrahedron(; radius::Real=1.0)

Constructs Cookson solid C5: Gyrotrapezotrigonal Octasphere (V=38, F=48).
- Polygon Root: Gyrotrapezotrigonal | Symmetry: Octasphere | Parent Catalan: Pentagonal Icositetrahedron
- Derivation: Convex projection of the Pentagonal Icositetrahedron (24 trapezoids, 24 triangles).
"""
function gyrotrapezotrigonal_octasphere(; radius::Real=1.0)
    return cookson(pentagonal_icositetrahedron(); radius=radius)
end
const cooksonian_pentagonal_icositetrahedron = gyrotrapezotrigonal_octasphere

"""
    gyrotrapezotrigonal_icosasphere(; radius::Real=1.0)
    cooksonian_pentagonal_hexecontahedron(; radius::Real=1.0)

Constructs Cookson solid C6: Gyrotrapezotrigonal Icosasphere (V=92, F=120).
- Polygon Root: Gyrotrapezotrigonal | Symmetry: Icosasphere | Parent Catalan: Pentagonal Hexecontahedron
- Derivation: Convex projection of the Pentagonal Hexecontahedron (60 trapezoids, 60 triangles).
"""
function gyrotrapezotrigonal_icosasphere(; radius::Real=1.0)
    return cookson(pentagonal_hexecontahedron(); radius=radius)
end
const cooksonian_pentagonal_hexecontahedron = gyrotrapezotrigonal_icosasphere

# ============================================================================
# The 6 Concave Cookson Regimes (C7 - C12) - The Hidden Shadows
# ============================================================================

function _valley_crease_quads(parent_solid::Polyhedron, radius::Real)
    P = _clean_face_order(parent_solid)
    r = Float64(radius)
    v_sph = Pt3{Float64}[r * (v / norm(v)) for v in P.v]
    faces = Vector{Int}[]
    for f in P.f
        d13 = norm(v_sph[f[1]] - v_sph[f[3]])
        d24 = norm(v_sph[f[2]] - v_sph[f[4]])
        if d13 >= d24
            push!(faces, [f[1], f[2], f[3]], [f[1], f[3], f[4]])
        else
            push!(faces, [f[1], f[2], f[4]], [f[2], f[3], f[4]])
        end
    end
    return Polyhedron(v_sph, faces)
end

function _valley_crease_pentakites(parent_solid::Polyhedron, radius::Real)
    P = _clean_face_order(parent_solid)
    r = Float64(radius)
    v_sph = Pt3{Float64}[r * (v / norm(v)) for v in P.v]
    faces = Vector{Int}[]
    
    for f in P.f
        edge_lens = [norm(v_sph[f[i]] - v_sph[f[mod1(i+1, 5)]]) for i in 1:5]
        tip_idx = 1
        max_adj_sum = -1.0
        for i in 1:5
            prev_e = edge_lens[mod1(i - 1, 5)]
            next_e = edge_lens[i]
            if prev_e + next_e > max_adj_sum
                max_adj_sum = prev_e + next_e
                tip_idx = i
            end
        end
        
        v0 = f[tip_idx]
        v1 = f[mod1(tip_idx + 1, 5)]
        v2 = f[mod1(tip_idx + 2, 5)]
        v3 = f[mod1(tip_idx + 3, 5)]
        v4 = f[mod1(tip_idx + 4, 5)]
        
        push!(faces, [v0, v1, v2], [v0, v2, v3], [v0, v3, v4])
    end
    return Polyhedron(v_sph, faces)
end

"""
    concave_trigonal_octasphere(; radius::Real=1.0)

Constructs Cookson solid C7 (V=14, F=24).
- Polygon Root: Trigonal | Symmetry: Octasphere | Parent Catalan: Rhombic Dodecahedron
- Derivation: The valley-creased (concave) shadow of C1.
"""
function concave_trigonal_octasphere(; radius::Real=1.0)
    return _valley_crease_quads(rhombic_dodecahedron(), radius)
end

"""
    concave_trigonal_icosasphere(; radius::Real=1.0)

Constructs Cookson solid C8 (V=32, F=60).
- Polygon Root: Trigonal | Symmetry: Icosasphere | Parent Catalan: Rhombic Triacontahedron
- Derivation: The valley-creased (concave) shadow of C2.
"""
function concave_trigonal_icosasphere(; radius::Real=1.0)
    return _valley_crease_quads(rhombic_triacontahedron(), radius)
end

"""
    concave_bitrigonal_octasphere(; radius::Real=1.0)

Constructs Cookson solid C9 (V=26, F=48).
- Polygon Root: Bitrigonal | Symmetry: Octasphere | Parent Catalan: Deltoidal Icositetrahedron
- Derivation: The valley-creased (concave) shadow of C3.
"""
function concave_bitrigonal_octasphere(; radius::Real=1.0)
    return _valley_crease_quads(deltoidal_icositetrahedron(), radius)
end

"""
    concave_bitrigonal_icosasphere(; radius::Real=1.0)

Constructs Cookson solid C10 (V=62, F=120).
- Polygon Root: Bitrigonal | Symmetry: Icosasphere | Parent Catalan: Deltoidal Hexecontahedron
- Derivation: The valley-creased (concave) shadow of C4.
"""
function concave_bitrigonal_icosasphere(; radius::Real=1.0)
    return _valley_crease_quads(deltoidal_hexecontahedron(), radius)
end

"""
    concave_gyrotrapezotrigonal_octasphere(; radius::Real=1.0)

Constructs Cookson solid C11 (V=38, F=72).
- Polygon Root: Gyrotrapezotrigonal | Symmetry: Octasphere | Parent Catalan: Pentagonal Icositetrahedron
- Derivation: The valley-creased shadow of C5. Fractures each skew pentakite from the tip to the lower vertices,
  producing 24 central isosceles triangles and 48 mirrored flanking scalene triangles (2 geometric types).
"""
function concave_gyrotrapezotrigonal_octasphere(; radius::Real=1.0)
    return _valley_crease_pentakites(pentagonal_icositetrahedron(), radius)
end

"""
    concave_gyrotrapezotrigonal_icosasphere(; radius::Real=1.0)

Constructs Cookson solid C12 (V=92, F=180).
- Polygon Root: Gyrotrapezotrigonal | Symmetry: Icosasphere | Parent Catalan: Pentagonal Hexecontahedron
- Derivation: The valley-creased shadow of C6 (60 central isosceles triangles and 120 mirrored flanking scalene triangles).
"""
function concave_gyrotrapezotrigonal_icosasphere(; radius::Real=1.0)
    return _valley_crease_pentakites(pentagonal_hexecontahedron(), radius)
end

# ============================================================================
# Metadata, Classification & Dispatchers
# ============================================================================

struct CooksonMeta
    index::Int
    name::String
    polygon_root::String
    symmetry::String
    parent_catalan::String
    regime_type::String
end

const COOKSON_SOLIDS_TABLE = [
    # Convex Regimes (C1 - C6)
    CooksonMeta(1, "Trigonal Octasphere", "Trigonal", "Octasphere", "Rhombic Dodecahedron", "Convex"),
    CooksonMeta(2, "Trigonal Icosasphere", "Trigonal", "Icosasphere", "Rhombic Triacontahedron", "Convex"),
    CooksonMeta(3, "Bitrigonal Octasphere", "Bitrigonal", "Octasphere", "Deltoidal Icositetrahedron", "Convex"),
    CooksonMeta(4, "Bitrigonal Icosasphere", "Bitrigonal", "Icosasphere", "Deltoidal Hexecontahedron", "Convex"),
    CooksonMeta(5, "Gyrotrapezotrigonal Octasphere", "Gyrotrapezotrigonal", "Octasphere", "Pentagonal Icositetrahedron", "Convex"),
    CooksonMeta(6, "Gyrotrapezotrigonal Icosasphere", "Gyrotrapezotrigonal", "Icosasphere", "Pentagonal Hexecontahedron", "Convex"),

    # Concave Regimes (C7 - C12) - The Hidden Shadows
    CooksonMeta(7, "Concave Trigonal Octasphere", "Trigonal", "Octasphere", "Rhombic Dodecahedron", "Concave (Valley Shadow)"),
    CooksonMeta(8, "Concave Trigonal Icosasphere", "Trigonal", "Icosasphere", "Rhombic Triacontahedron", "Concave (Valley Shadow)"),
    CooksonMeta(9, "Concave Bitrigonal Octasphere", "Bitrigonal", "Octasphere", "Deltoidal Icositetrahedron", "Concave (Valley Shadow)"),
    CooksonMeta(10, "Concave Bitrigonal Icosasphere", "Bitrigonal", "Icosasphere", "Deltoidal Hexecontahedron", "Concave (Valley Shadow)"),
    CooksonMeta(11, "Concave Gyrotrapezotrigonal Octasphere", "Gyrotrapezotrigonal", "Octasphere", "Pentagonal Icositetrahedron", "Concave (Valley Shadow)"),
    CooksonMeta(12, "Concave Gyrotrapezotrigonal Icosasphere", "Gyrotrapezotrigonal", "Icosasphere", "Pentagonal Hexecontahedron", "Concave (Valley Shadow)")
]

const COOKSON_SOLID_NAMES = [m.name for m in COOKSON_SOLIDS_TABLE]

const COOKSON_SOLID_ORDER = [
    :trigonal_octasphere,
    :trigonal_icosasphere,
    :bitrigonal_octasphere,
    :bitrigonal_icosasphere,
    :gyrotrapezotrigonal_octasphere,
    :gyrotrapezotrigonal_icosasphere,
    :concave_trigonal_octasphere,
    :concave_trigonal_icosasphere,
    :concave_bitrigonal_octasphere,
    :concave_bitrigonal_icosasphere,
    :concave_gyrotrapezotrigonal_octasphere,
    :concave_gyrotrapezotrigonal_icosasphere
]

const COOKSON_SOLID_MAP = Dict{Symbol, Function}(
    # Official names (Convex)
    :trigonal_octasphere => trigonal_octasphere,
    :trigonal_icosasphere => trigonal_icosasphere,
    :bitrigonal_octasphere => bitrigonal_octasphere,
    :bitrigonal_icosasphere => bitrigonal_icosasphere,
    :gyrotrapezotrigonal_octasphere => gyrotrapezotrigonal_octasphere,
    :gyrotrapezotrigonal_icosasphere => gyrotrapezotrigonal_icosasphere,

    # Official names (Concave)
    :concave_trigonal_octasphere => concave_trigonal_octasphere,
    :concave_trigonal_icosasphere => concave_trigonal_icosasphere,
    :concave_bitrigonal_octasphere => concave_bitrigonal_octasphere,
    :concave_bitrigonal_icosasphere => concave_bitrigonal_icosasphere,
    :concave_gyrotrapezotrigonal_octasphere => concave_gyrotrapezotrigonal_octasphere,
    :concave_gyrotrapezotrigonal_icosasphere => concave_gyrotrapezotrigonal_icosasphere,

    # Shorthand symbols :C1 to :C12
    :C1 => trigonal_octasphere, :c1 => trigonal_octasphere,
    :C2 => trigonal_icosasphere, :c2 => trigonal_icosasphere,
    :C3 => bitrigonal_octasphere, :c3 => bitrigonal_octasphere,
    :C4 => bitrigonal_icosasphere, :c4 => bitrigonal_icosasphere,
    :C5 => gyrotrapezotrigonal_octasphere, :c5 => gyrotrapezotrigonal_octasphere,
    :C6 => gyrotrapezotrigonal_icosasphere, :c6 => gyrotrapezotrigonal_icosasphere,
    :C7 => concave_trigonal_octasphere, :c7 => concave_trigonal_octasphere,
    :C8 => concave_trigonal_icosasphere, :c8 => concave_trigonal_icosasphere,
    :C9 => concave_bitrigonal_octasphere, :c9 => concave_bitrigonal_octasphere,
    :C10 => concave_bitrigonal_icosasphere, :c10 => concave_bitrigonal_icosasphere,
    :C11 => concave_gyrotrapezotrigonal_octasphere, :c11 => concave_gyrotrapezotrigonal_octasphere,
    :C12 => concave_gyrotrapezotrigonal_icosasphere, :c12 => concave_gyrotrapezotrigonal_icosasphere,

    # Catalan parent aliases
    :cooksonian_rhombic_dodecahedron => trigonal_octasphere,
    :cooksonian_rhombic_triacontahedron => trigonal_icosasphere,
    :cooksonian_deltoidal_icositetrahedron => bitrigonal_octasphere,
    :cooksonian_deltoidal_hexecontahedron => bitrigonal_icosasphere,
    :cooksonian_pentagonal_icositetrahedron => gyrotrapezotrigonal_octasphere,
    :cooksonian_pentagonal_hexecontahedron => gyrotrapezotrigonal_icosasphere
)

"""
    cookson_names()

Returns the list of official names for the 12 Cookson solids (C1 to C12).
"""
cookson_names() = copy(COOKSON_SOLID_NAMES)

"""
    cookson_name(index::Integer)

Returns the official name string for the Cookson solid at index 1 to 12.
"""
function cookson_name(index::Integer)
    1 <= index <= 12 || error("Cookson solid index must be between 1 and 12 (got index=$index).")
    return COOKSON_SOLID_NAMES[index]
end

"""
    cookson_info(index::Integer)
    cookson_info(name::Symbol)

Returns structural metadata (name, polygon root, symmetry, parent Catalan solid, regime type) for a Cookson solid.
"""
function cookson_info(index::Integer)
    1 <= index <= 12 || error("Cookson solid index must be between 1 and 12 (got index=$index).")
    return COOKSON_SOLIDS_TABLE[index]
end

function cookson_info(name::Symbol)
    s_str = uppercase(string(name))
    if startswith(s_str, "C") && length(s_str) in (2, 3) && all(isdigit, s_str[2:end])
        idx = parse(Int, s_str[2:end])
        if 1 <= idx <= 12
            return cookson_info(idx)
        end
    end
    idx = findfirst(==(name), COOKSON_SOLID_ORDER)
    if idx !== nothing
        return COOKSON_SOLIDS_TABLE[idx]
    end
    error("Unknown Cookson solid: $name")
end

"""
    cookson(name::Symbol; radius::Real=1.0)
    cookson(index::Integer; radius::Real=1.0)

Access any of the 12 Cookson solid regimes by official name symbol, index (1-12), or shorthand (`:C1` - `:C12`).
"""
function cookson(name::Symbol; radius::Real=1.0)
    haskey(COOKSON_SOLID_MAP, name) || error("Unknown Cookson solid: $name. Available: $(keys(COOKSON_SOLID_MAP))")
    return COOKSON_SOLID_MAP[name](; radius=radius)
end

function cookson(index::Integer; radius::Real=1.0)
    1 <= index <= 12 || error("Cookson solid index must be between 1 and 12 (got index=$index).")
    return cookson(COOKSON_SOLID_ORDER[index]; radius=radius)
end
