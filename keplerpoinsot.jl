"""
Kepler-Poinsot star polyhedra generators returning `Polyhedron` objects.
All 4 regular non-convex (star) polyhedra with regular faces and symmetric vertices.
"""

"""
    great_dodecahedron()

Constructs a great dodecahedron ({5, 5/2}, 12 vertices of icosahedron, 60 triangular boundary facets).
"""
function great_dodecahedron()
    ico = icosahedron()
    v_all = Pt3{Float64}[v for v in ico.v]
    f_all = Vector{Int}[]
    for (f_idx, face) in enumerate(ico.f)
        pts = [ico.v[i] for i in face]
        c = sum(pts) / 3
        n = normalize(c)
        apex_r = norm(c) * (3 - sqrt(5))
        push!(v_all, Pt3{Float64}(n * apex_r))
        apex_idx = length(v_all)
        push!(f_all, [face[1], face[2], apex_idx])
        push!(f_all, [face[2], face[3], apex_idx])
        push!(f_all, [face[3], face[1], apex_idx])
    end
    return Polyhedron(v_all, f_all)
end

"""
    small_stellated_dodecahedron()

Constructs a small stellated dodecahedron ({5/2, 5}, 12 star pyramid points on dodecahedron faces, 60 triangular facets).
Dual of the Great Dodecahedron.
"""
function small_stellated_dodecahedron()
    ϕ = (1 + sqrt(5)) / 2
    dod = dodecahedron()
    v_all = Pt3{Float64}[v for v in dod.v]
    f_all = Vector{Int}[]
    for (f_idx, face) in enumerate(dod.f)
        pts = [dod.v[i] for i in face]
        c = sum(pts) / 5
        n = normalize(c)
        apex_r = norm(c) * ϕ^2
        push!(v_all, Pt3{Float64}(n * apex_r))
        apex_idx = length(v_all)
        n_pts = length(face)
        for i in 1:n_pts
            u = face[i]
            v = face[i == n_pts ? 1 : i + 1]
            push!(f_all, [u, v, apex_idx])
        end
    end
    return Polyhedron(v_all, f_all)
end

"""
    great_stellated_dodecahedron()

Constructs a great stellated dodecahedron ({5/2, 3}, 20 star pyramid spikes on icosahedron faces, 60 triangular facets).
Dual of the Great Icosahedron.
"""
function great_stellated_dodecahedron()
    ϕ = (1 + sqrt(5)) / 2
    ico = icosahedron()
    v_all = Pt3{Float64}[v for v in ico.v]
    f_all = Vector{Int}[]
    for (f_idx, face) in enumerate(ico.f)
        pts = [ico.v[i] for i in face]
        c = sum(pts) / 3
        n = normalize(c)
        apex_r = norm(c) * (2*ϕ - 1)
        push!(v_all, Pt3{Float64}(n * apex_r))
        apex_idx = length(v_all)
        push!(f_all, [face[1], face[2], apex_idx])
        push!(f_all, [face[2], face[3], apex_idx])
        push!(f_all, [face[3], face[1], apex_idx])
    end
    return Polyhedron(v_all, f_all)
end

"""
    great_icosahedron()

Constructs a great icosahedron ({3, 5/2}, 12 five-pointed star apexes, 60 triangular boundary facets).
Dual of the Great Stellated Dodecahedron.
"""
function great_icosahedron()
    ϕ = (1 + sqrt(5)) / 2
    ico = icosahedron()
    dod = dual(ico)
    v_gi = Pt3{Float64}[]
    for v in ico.v
        push!(v_gi, Pt3{Float64}(normalize(v) * ϕ))
    end
    for v in dod.v
        push!(v_gi, Pt3{Float64}(normalize(v) * (3 - sqrt(5))))
    end

    f_gi = Vector{Int}[]
    for v_idx in 1:12
        incident_ico_faces = [f_idx for (f_idx, f) in enumerate(ico.f) if v_idx in f]
        pts = [v_gi[12 + f_idx] for f_idx in incident_ico_faces]
        axis = normalize(v_gi[v_idx])
        ref = pts[1] - (pts[1] ⋅ axis) * axis
        ref /= norm(ref)
        perp = axis × ref
        angles = [atan(p ⋅ perp, p ⋅ ref) for p in pts]
        ordered_faces = incident_ico_faces[sortperm(angles)]
        
        for k in 1:5
            in1 = 12 + ordered_faces[k]
            in2 = 12 + ordered_faces[k == 5 ? 1 : k + 1]
            push!(f_gi, [v_idx, in1, in2])
        end
    end
    return Polyhedron(v_gi, f_gi)
end

const KEPLER_POINSOT_SOLID_MAP = Dict{Symbol, Function}(
    :great_dodecahedron => great_dodecahedron,
    :small_stellated_dodecahedron => small_stellated_dodecahedron,
    :great_stellated_dodecahedron => great_stellated_dodecahedron,
    :great_icosahedron => great_icosahedron
)

const KEPLER_POINSOT_SOLID_ORDER = [
    :great_dodecahedron,
    :small_stellated_dodecahedron,
    :great_stellated_dodecahedron,
    :great_icosahedron
]

"""
    kepler_poinsot(name::Symbol)
    kepler_poinsot(index::Integer)

Access any of the 4 Kepler-Poinsot solids by name symbol or index (1-4).
"""
function kepler_poinsot(name::Symbol)
    haskey(KEPLER_POINSOT_SOLID_MAP, name) || error("Unknown Kepler-Poinsot solid: $name. Available: $(keys(KEPLER_POINSOT_SOLID_MAP))")
    return KEPLER_POINSOT_SOLID_MAP[name]()
end

function kepler_poinsot(index::Integer)
    1 <= index <= 4 || error("Kepler-Poinsot solid index must be between 1 and 4.")
    return kepler_poinsot(KEPLER_POINSOT_SOLID_ORDER[index])
end
