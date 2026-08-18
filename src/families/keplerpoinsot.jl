"""
Kepler-Poinsot star polyhedra generators returning `Polyhedron` objects.
All 4 regular non-convex (star) polyhedra with regular faces and symmetric vertices.
"""

"""
    great_dodecahedron()

Constructs a great dodecahedron ({5, 5/2}, 12 vertices of regular icosahedron, 12 intersecting regular pentagonal faces).
"""
function great_dodecahedron()
    ico = icosahedron()
    v_ico = ico.v
    gd_faces = Vector{Int}[]
    for i in 1:12
        nbrs = [j for j in 1:12 if i != j && isapprox(norm(v_ico[i] - v_ico[j]), 2.0; atol=1e-3)]
        axis = normalize(v_ico[i])
        ref = v_ico[nbrs[1]] - (v_ico[nbrs[1]] ⋅ axis) * axis
        ref /= norm(ref)
        perp = axis × ref
        angles = [atan(v_ico[j] ⋅ perp, v_ico[j] ⋅ ref) for j in nbrs]
        push!(gd_faces, nbrs[sortperm(angles)])
    end
    return Polyhedron(v_ico, gd_faces)
end

"""
    small_stellated_dodecahedron()

Constructs a small stellated dodecahedron ({5/2, 5}, 12 vertices of regular icosahedron, 12 intersecting pentagram star faces).
For each of the 12 icosahedral vertices, its 5 nearest neighbors form a regular pentagram.
Dual of the Great Dodecahedron.
"""
function small_stellated_dodecahedron()
    ico = icosahedron()
    v_ico = ico.v
    ssd_faces = Vector{Int}[]
    for i in 1:12
        nbrs = [j for j in 1:12 if i != j && isapprox(norm(v_ico[i] - v_ico[j]), 2.0; atol=1e-3)]
        axis = normalize(v_ico[i])
        ref = v_ico[nbrs[1]] - (v_ico[nbrs[1]] ⋅ axis) * axis
        ref /= norm(ref)
        perp = axis × ref
        angles = [atan(v_ico[j] ⋅ perp, v_ico[j] ⋅ ref) for j in nbrs]
        ord = nbrs[sortperm(angles)]
        push!(ssd_faces, ord[[1, 3, 5, 2, 4]])
    end
    return Polyhedron(v_ico, ssd_faces)
end

"""
    great_stellated_dodecahedron()

Constructs a great stellated dodecahedron ({5/2, 3}, 20 vertices of regular dodecahedron, 12 intersecting pentagram star faces).
Along each of the 6 five-fold axes, the 20 vertices form 4 layers of 5 vertices, where the 2 middle layers each form a regular pentagram.
Dual of the Great Icosahedron.
"""
function great_stellated_dodecahedron()
    dod = dodecahedron()
    v_dod = dod.v
    face_normals = [normalize(sum([v_dod[i] for i in f])) for f in dod.f]
    unique_axes = Pt3{Float64}[]
    for n in face_normals
        if !any(isapprox(abs(dot(n, a)), 1.0; atol=1e-4) for a in unique_axes)
            push!(unique_axes, n)
        end
    end

    gsd_faces = Vector{Int}[]
    for axis in unique_axes
        heights = [dot(v_dod[i], axis) for i in 1:20]
        perm = sortperm(heights)
        layer2 = perm[6:10]   # lower middle layer
        layer3 = perm[11:15]  # upper middle layer
        
        for layer in [layer2, layer3]
            pts = [v_dod[k] for k in layer]
            ref = pts[1] - (pts[1] ⋅ axis) * axis
            ref /= norm(ref)
            perp = axis × ref
            angles = [atan(p ⋅ perp, p ⋅ ref) for p in pts]
            ord = layer[sortperm(angles)]
            push!(gsd_faces, ord[[1, 3, 5, 2, 4]])
        end
    end
    return Polyhedron(v_dod, gsd_faces)
end

"""
    great_icosahedron()

Constructs a great icosahedron ({3, 5/2}, 12 vertices of regular icosahedron, 20 intersecting equilateral triangular faces).
Dual of the Great Stellated Dodecahedron.
"""
function great_icosahedron()
    ico = icosahedron()
    v_ico = ico.v
    ϕ = (1.0 + sqrt(5.0)) / 2.0
    gi_faces = Vector{Int}[]
    for i in 1:12, j in (i+1):12, k in (j+1):12
        d1 = norm(v_ico[i] - v_ico[j])
        d2 = norm(v_ico[j] - v_ico[k])
        d3 = norm(v_ico[k] - v_ico[i])
        if isapprox(d1, d2; atol=1e-3) && isapprox(d2, d3; atol=1e-3) && isapprox(d1, 2*ϕ; atol=1e-3)
            c = (v_ico[i] + v_ico[j] + v_ico[k]) / 3
            n = (v_ico[j] - v_ico[i]) × (v_ico[k] - v_ico[i])
            if dot(n, c) < 0
                push!(gi_faces, [i, k, j])
            else
                push!(gi_faces, [i, j, k])
            end
        end
    end
    return Polyhedron(v_ico, gi_faces)
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
