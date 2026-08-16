# The Cookson Solids (Topological Regimes)
# Formalized and discovered by Arthur J. Cookson and Joel T. Harter in 2026.
#
# Sequence Prefix: H (Harter) — H1, H2, H3... to avoid namespace collisions with Catalan solids (C).
# Suffix Rule: -sphere is applied because vertices are mathematically normalized to the unit sphere.
#
# The "Studded" Nomenclature:
# Traditional Greek prefixes (e.g. triakis, tetrakis, pentakis, disdyakis) are strictly banned in this namespace.
# Archaic prefixes are replaced with the intuitive modifier "Studded" (or "Bi-studded" for dual-triangulation).
#
# Taxonomic Exclusion Rules:
# - Rule A (Disqualification Gate): Disqualifies regimes sharing both the topological graph AND strict convexity
#   with established classical solids.
# - Rule B (Exclusion Roster): Disqualified solids are logged in an unnumbered Excluded list (-sphere suffix).
# - Rule C (Concavity Exception): Regimes with classical graphs but different convexity (concave valley folds)
#   bypass Rule A and are inducted as official Cookson solids (The Concave Shadows).

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

Constructs the canonical convex Cookson projection corresponding to a polyhedron `P` by projecting its
vertices onto a sphere of the given `radius`, and restoring 3D planarity via convex hull.
"""
function cookson(P::Polyhedron; radius::Real=1.0)
    v_sph = Pt3{Float64}[radius * (v / norm(v)) for v in P.v]
    return convex_hull(v_sph; merge_coplanar=true)
end

# Internal helpers for valley creasing
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

# ============================================================================
# The Official Cookson Sequence (H1 - H8)
# ============================================================================

# --- The Convex Irregulars (Unique Graphs) ---

"""
    gyrotrapezotrigonal_octasphere(; radius::Real=1.0)
    cookson(:H1; radius::Real=1.0)

Constructs Cookson solid H1: Gyrotrapezotrigonal Octasphere (V=38, F=48).
- Classification: Convex Irregular (Unique Graph)
- Derivation: Art's original convex Pentagonal Icositetrahedron derivative (24 trapezoids, 24 triangles).
"""
function gyrotrapezotrigonal_octasphere(; radius::Real=1.0)
    return cookson(pentagonal_icositetrahedron(); radius=radius)
end

"""
    gyrotrapezotrigonal_icosasphere(; radius::Real=1.0)
    cookson(:H2; radius::Real=1.0)

Constructs Cookson solid H2: Gyrotrapezotrigonal Icosasphere (V=92, F=120).
- Classification: Convex Irregular (Unique Graph)
- Derivation: Art's original convex Pentagonal Hexecontahedron derivative (60 trapezoids, 60 triangles).
"""
function gyrotrapezotrigonal_icosasphere(; radius::Real=1.0)
    return cookson(pentagonal_hexecontahedron(); radius=radius)
end

# --- The Concave Shadows (Classical Graphs, Different Convexity) ---

"""
    studded_octasphere(; radius::Real=1.0)
    cookson(:H3; radius::Real=1.0)

Constructs Cookson solid H3: Studded Octasphere (V=14, F=24).
- Classification: Concave Shadow (Rule C Concavity Exception)
- Classical Graph: Triakis Octahedron
- Derivation: Concave valley-fold derivative of the Rhombic Dodecahedron (24 congruent triangles).
"""
function studded_octasphere(; radius::Real=1.0)
    return _valley_crease_quads(rhombic_dodecahedron(), radius)
end

"""
    studded_icosasphere(; radius::Real=1.0)
    cookson(:H4; radius::Real=1.0)

Constructs Cookson solid H4: Studded Icosasphere (V=32, F=60).
- Classification: Concave Shadow (Rule C Concavity Exception)
- Classical Graph: Triakis Icosahedron
- Derivation: Concave valley-fold derivative of the Rhombic Triacontahedron (60 congruent triangles).
"""
function studded_icosasphere(; radius::Real=1.0)
    return _valley_crease_quads(rhombic_triacontahedron(), radius)
end

"""
    bistudded_cuboctasphere(; radius::Real=1.0)
    bi_studded_cuboctasphere(; radius::Real=1.0)
    cookson(:H5; radius::Real=1.0)

Constructs Cookson solid H5: Bi-studded Cuboctasphere (V=26, F=48).
- Classification: Concave Shadow (Rule C Concavity Exception)
- Classical Graph: Disdyakis Cuboctahedron
- Derivation: Concave valley-fold derivative of the Deltoidal Icositetrahedron (48 triangles in chiral pairs).
"""
function bistudded_cuboctasphere(; radius::Real=1.0)
    return _valley_crease_quads(deltoidal_icositetrahedron(), radius)
end
const bi_studded_cuboctasphere = bistudded_cuboctasphere

"""
    bistudded_rhombic_triacontasphere(; radius::Real=1.0)
    bi_studded_rhombic_triacontasphere(; radius::Real=1.0)
    cookson(:H6; radius::Real=1.0)

Constructs Cookson solid H6: Bi-studded Rhombic Triacontasphere (V=62, F=120).
- Classification: Concave Shadow (Rule C Concavity Exception)
- Classical Graph: Disdyakis Rhombic Triacontahedron
- Derivation: Concave valley-fold derivative of the Deltoidal Hexecontahedron (120 triangles in chiral pairs).
"""
function bistudded_rhombic_triacontasphere(; radius::Real=1.0)
    return _valley_crease_quads(deltoidal_hexecontahedron(), radius)
end
const bi_studded_rhombic_triacontasphere = bistudded_rhombic_triacontasphere

# --- The Concave Irregulars (Unique Graphs, Unique Convexity) ---

"""
    gyrobitrigonal_octasphere(; radius::Real=1.0)
    cookson(:H7; radius::Real=1.0)

Constructs Cookson solid H7: Gyrobitrigonal Octasphere (V=38, F=72).
- Classification: Concave Irregular (Unique Graph & Convexity)
- Derivation: Concave valley-fold derivative of the Pentagonal Icositetrahedron (24 central isosceles + 48 flanking scalene triangles).
"""
function gyrobitrigonal_octasphere(; radius::Real=1.0)
    return _valley_crease_pentakites(pentagonal_icositetrahedron(), radius)
end

"""
    gyrobitrigonal_icosasphere(; radius::Real=1.0)
    cookson(:H8; radius::Real=1.0)

Constructs Cookson solid H8: Gyrobitrigonal Icosasphere (V=92, F=180).
- Classification: Concave Irregular (Unique Graph & Convexity)
- Derivation: Concave valley-fold derivative of the Pentagonal Hexecontahedron (60 central isosceles + 120 flanking scalene triangles).
"""
function gyrobitrigonal_icosasphere(; radius::Real=1.0)
    return _valley_crease_pentakites(pentagonal_hexecontahedron(), radius)
end

# ============================================================================
# The Excluded Solids List (Unnumbered under Rule A)
# ============================================================================

"""
    studded_hexasphere(; radius::Real=1.0)

Excluded solid: Derived from convex projection of Rhombic Dodecahedron (V=14, F=24).
Disqualified under Rule A (shares topological graph and convexity with Catalan Tetrakis Hexahedron).
"""
studded_hexasphere(; radius::Real=1.0) = cookson(rhombic_dodecahedron(); radius=radius)

"""
    studded_dodecasphere(; radius::Real=1.0)

Excluded solid: Derived from convex projection of Rhombic Triacontahedron (V=32, F=60).
Disqualified under Rule A (shares topological graph and convexity with Catalan Pentakis Dodecahedron).
"""
studded_dodecasphere(; radius::Real=1.0) = cookson(rhombic_triacontahedron(); radius=radius)

"""
    bistudded_dodecasphere(; radius::Real=1.0)
    bi_studded_dodecasphere(; radius::Real=1.0)

Excluded solid: Derived from convex projection of Deltoidal Icositetrahedron (V=26, F=48).
Disqualified under Rule A (shares topological graph and convexity with Catalan Disdyakis Dodecahedron).
"""
bistudded_dodecasphere(; radius::Real=1.0) = cookson(deltoidal_icositetrahedron(); radius=radius)
const bi_studded_dodecasphere = bistudded_dodecasphere

"""
    bistudded_triacontasphere(; radius::Real=1.0)
    bi_studded_triacontasphere(; radius::Real=1.0)

Excluded solid: Derived from convex projection of Deltoidal Hexecontahedron (V=62, F=120).
Disqualified under Rule A (shares topological graph and convexity with Catalan Disdyakis Triacontahedron).
"""
bistudded_triacontasphere(; radius::Real=1.0) = cookson(deltoidal_hexecontahedron(); radius=radius)
const bi_studded_triacontasphere = bistudded_triacontasphere

# ============================================================================
# Metadata, Classification & Dispatchers
# ============================================================================

struct CooksonMeta
    h_index::Int
    name::String
    group::String
    polygon_root::String
    symmetry::String
    parent_catalan::String
    classical_graph::String
end

const COOKSON_SOLIDS_TABLE = [
    # Convex Irregulars (H1 - H2)
    CooksonMeta(1, "Gyrotrapezotrigonal Octasphere", "Convex Irregular", "Gyrotrapezotrigonal", "Octasphere", "Pentagonal Icositetrahedron", "Unique"),
    CooksonMeta(2, "Gyrotrapezotrigonal Icosasphere", "Convex Irregular", "Gyrotrapezotrigonal", "Icosasphere", "Pentagonal Hexecontahedron", "Unique"),

    # Concave Shadows (H3 - H6)
    CooksonMeta(3, "Studded Octasphere", "Concave Shadow", "Studded", "Octasphere", "Rhombic Dodecahedron", "Triakis Octahedron"),
    CooksonMeta(4, "Studded Icosasphere", "Concave Shadow", "Studded", "Icosasphere", "Rhombic Triacontahedron", "Triakis Icosahedron"),
    CooksonMeta(5, "Bi-studded Cuboctasphere", "Concave Shadow", "Bi-studded", "Octasphere", "Deltoidal Icositetrahedron", "Disdyakis Cuboctahedron"),
    CooksonMeta(6, "Bi-studded Rhombic Triacontasphere", "Concave Shadow", "Bi-studded", "Icosasphere", "Deltoidal Hexecontahedron", "Disdyakis Rhombic Triacontahedron"),

    # Concave Irregulars (H7 - H8)
    CooksonMeta(7, "Gyrobitrigonal Octasphere", "Concave Irregular", "Gyrobitrigonal", "Octasphere", "Pentagonal Icositetrahedron", "Unique"),
    CooksonMeta(8, "Gyrobitrigonal Icosasphere", "Concave Irregular", "Gyrobitrigonal", "Icosasphere", "Pentagonal Hexecontahedron", "Unique")
]

const COOKSON_SOLID_NAMES = [m.name for m in COOKSON_SOLIDS_TABLE]

const COOKSON_SOLID_ORDER = [
    :gyrotrapezotrigonal_octasphere,
    :gyrotrapezotrigonal_icosasphere,
    :studded_octasphere,
    :studded_icosasphere,
    :bistudded_cuboctasphere,
    :bistudded_rhombic_triacontasphere,
    :gyrobitrigonal_octasphere,
    :gyrobitrigonal_icosasphere
]

const EXCLUDED_COOKSON_MAP = Dict{Symbol, Function}(
    :studded_hexasphere => studded_hexasphere,
    :studded_dodecasphere => studded_dodecasphere,
    :bistudded_dodecasphere => bistudded_dodecasphere,
    :bi_studded_dodecasphere => bistudded_dodecasphere,
    :bistudded_triacontasphere => bistudded_triacontasphere,
    :bi_studded_triacontasphere => bistudded_triacontasphere
)

const EXCLUDED_COOKSON_NAMES = [
    "Studded Hexasphere",
    "Studded Dodecasphere",
    "Bi-studded Dodecasphere",
    "Bi-studded Triacontasphere"
]

const COOKSON_SOLID_MAP = Dict{Symbol, Function}(
    # Official names H1-H8
    :gyrotrapezotrigonal_octasphere => gyrotrapezotrigonal_octasphere,
    :gyrotrapezotrigonal_icosasphere => gyrotrapezotrigonal_icosasphere,
    :studded_octasphere => studded_octasphere,
    :studded_icosasphere => studded_icosasphere,
    :bistudded_cuboctasphere => bistudded_cuboctasphere,
    :bi_studded_cuboctasphere => bistudded_cuboctasphere,
    :bistudded_rhombic_triacontasphere => bistudded_rhombic_triacontasphere,
    :bi_studded_rhombic_triacontasphere => bistudded_rhombic_triacontasphere,
    :gyrobitrigonal_octasphere => gyrobitrigonal_octasphere,
    :gyrobitrigonal_icosasphere => gyrobitrigonal_icosasphere,

    # H-prefix shorthands :H1 to :H8
    :H1 => gyrotrapezotrigonal_octasphere, :h1 => gyrotrapezotrigonal_octasphere,
    :H2 => gyrotrapezotrigonal_icosasphere, :h2 => gyrotrapezotrigonal_icosasphere,
    :H3 => studded_octasphere, :h3 => studded_octasphere,
    :H4 => studded_icosasphere, :h4 => studded_icosasphere,
    :H5 => bistudded_cuboctasphere, :h5 => bistudded_cuboctasphere,
    :H6 => bistudded_rhombic_triacontasphere, :h6 => bistudded_rhombic_triacontasphere,
    :H7 => gyrobitrigonal_octasphere, :h7 => gyrobitrigonal_octasphere,
    :H8 => gyrobitrigonal_icosasphere, :h8 => gyrobitrigonal_icosasphere
)

"""
    cookson_names()

Returns the list of official names for the 8 Cookson solids (H1 to H8).
"""
cookson_names() = copy(COOKSON_SOLID_NAMES)

"""
    excluded_cookson_names()

Returns the list of names for the 4 disqualified spherical solids logged in the Exclusion Roster.
"""
excluded_cookson_names() = copy(EXCLUDED_COOKSON_NAMES)

"""
    cookson_name(index::Integer)

Returns the official name string for the Cookson solid at index 1 to 8 (H1 to H8).
"""
function cookson_name(index::Integer)
    1 <= index <= 8 || error("Cookson solid index must be between 1 and 8 (H1 to H8, got index=$index).")
    return COOKSON_SOLID_NAMES[index]
end

"""
    cookson_info(index::Integer)
    cookson_info(name::Symbol)

Returns structural metadata for a Cookson solid.
"""
function cookson_info(index::Integer)
    1 <= index <= 8 || error("Cookson solid index must be between 1 and 8 (H1 to H8, got index=$index).")
    return COOKSON_SOLIDS_TABLE[index]
end

function cookson_info(name::Symbol)
    s_str = uppercase(string(name))
    if startswith(s_str, "H") && length(s_str) in (2, 3) && all(isdigit, s_str[2:end])
        idx = parse(Int, s_str[2:end])
        if 1 <= idx <= 8
            return cookson_info(idx)
        end
    end
    idx = findfirst(==(name), COOKSON_SOLID_ORDER)
    if idx !== nothing
        return COOKSON_SOLIDS_TABLE[idx]
    end
    error("Unknown Cookson solid: $name. Available: H1 to H8.")
end

"""
    cookson(name::Symbol; radius::Real=1.0)
    cookson(index::Integer; radius::Real=1.0)

Access any of the 8 Cookson solid regimes by official name symbol, index (1-8), or shorthand (`:H1` - `:H8`).
"""
function cookson(name::Symbol; radius::Real=1.0)
    haskey(COOKSON_SOLID_MAP, name) || error("Unknown Cookson solid: $name. Available: :H1 through :H8 or official names.")
    return COOKSON_SOLID_MAP[name](; radius=radius)
end

function cookson(index::Integer; radius::Real=1.0)
    1 <= index <= 8 || error("Cookson solid index must be between 1 and 8 (H1 to H8, got index=$index).")
    return cookson(COOKSON_SOLID_ORDER[index]; radius=radius)
end

"""
    excluded_cookson(name::Symbol; radius::Real=1.0)

Accesses any of the 4 disqualified spherical regimes from the Exclusion Roster.
"""
function excluded_cookson(name::Symbol; radius::Real=1.0)
    haskey(EXCLUDED_COOKSON_MAP, name) || error("Unknown excluded solid: $name. Available: $(keys(EXCLUDED_COOKSON_MAP))")
    return EXCLUDED_COOKSON_MAP[name](; radius=radius)
end
