"""
Kepler-Poinsot star polyhedra generators returning `Polyhedron` objects.
All 4 regular non-convex (star) polyhedra with regular faces and symmetric vertices.
"""

"""
    great_dodecahedron()

Constructs a great dodecahedron (12 vertices, 12 intersecting pentagonal faces).
Schläfli symbol: {5, 5/2}.
"""
function great_dodecahedron()
    ico = icosahedron()
    v = ico.v
    faces = Vector{Int}[]
    
    for i in 1:12
        nbrs = [j for j in 1:12 if i != j && isapprox(norm(v[i] - v[j]), 2.0; atol=1e-4)]
        axis = v[i] / norm(v[i])
        ref = v[nbrs[1]] - (v[nbrs[1]] ⋅ axis) * axis
        ref /= norm(ref)
        perp = axis × ref
        angles = [atan((v[j] ⋅ perp), (v[j] ⋅ ref)) for j in nbrs]
        ordered = nbrs[sortperm(angles)]
        push!(faces, ordered)
    end
    
    return Polyhedron(v, faces)
end

"""
    small_stellated_dodecahedron()

Constructs a small stellated dodecahedron (12 vertices, 12 intersecting pentagram star faces).
Schläfli symbol: {5/2, 5}. Dual of the Great Dodecahedron.
"""
function small_stellated_dodecahedron()
    gd = great_dodecahedron()
    # Pentagram star order of the 5 pentagon vertices
    star_faces = [f[[1, 3, 5, 2, 4]] for f in gd.f]
    return Polyhedron(gd.v, star_faces)
end

"""
    great_stellated_dodecahedron()

Constructs a great stellated dodecahedron (20 vertices, 12 intersecting pentagram star faces).
Schläfli symbol: {5/2, 3}. Dual of the Great Icosahedron.
"""
function great_stellated_dodecahedron()
    dod = dodecahedron()
    # Pentagram star order of the 5 pentagon vertices
    star_faces = [f[[1, 3, 5, 2, 4]] for f in dod.f]
    return Polyhedron(dod.v, star_faces)
end

"""
    great_icosahedron()

Constructs a great icosahedron (12 vertices, 20 intersecting triangular faces).
Schläfli symbol: {3, 5/2}. Dual of the Great Stellated Dodecahedron.
"""
function great_icosahedron()
    ico = icosahedron()
    v = ico.v
    faces = Vector{Int}[]
    
    for i in 1:12
        for j in (i+1):12
            for k in (j+1):12
                d1 = norm(v[i] - v[j])
                d2 = norm(v[j] - v[k])
                d3 = norm(v[k] - v[i])
                # Intersecting triangles connect second-nearest neighbors in icosahedron
                if isapprox(d1, d2; atol=1e-4) && isapprox(d2, d3; atol=1e-4) && !isapprox(d1, 2.0; atol=1e-4) && d1 < 3.5
                    push!(faces, [i, j, k])
                end
            end
        end
    end
    
    return Polyhedron(v, faces)
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
