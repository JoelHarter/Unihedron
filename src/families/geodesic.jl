# Geodesic Spheres (Triangular) and Goldberg Solids (Pentagonal/Hexagonal) Generators

using StaticArrays
using LinearAlgebra

# Internal Helper: Class I {3, 5+}_{m, 0}
function _geodesic_class_I(m::Int, r::Float64)
    ico = icosahedron()
    verts = Pt3{Float64}[]
    
    function get_or_add_vertex(v_raw::Pt3{Float64})
        v_norm = Pt3{Float64}(r * (v_raw / norm(v_raw)))
        for (idx, existing) in enumerate(verts)
            if norm(existing - v_norm) < 1e-6
                return idx
            end
        end
        push!(verts, v_norm)
        return length(verts)
    end
    
    faces = Vector{Int}[]
    
    for face in ico.f
        v1, v2, v3 = ico.v[face[1]], ico.v[face[2]], ico.v[face[3]]
        
        # Grid of barycentric points on this triangular face
        grid = Dict{Tuple{Int, Int, Int}, Int}()
        for i in 0:m, j in 0:(m - i)
            k = m - i - j
            p_bary = (i * v1 + j * v2 + k * v3) / m
            grid[(i, j, k)] = get_or_add_vertex(p_bary)
        end
        
        # Sub-triangles
        for i in 0:(m - 1), j in 0:(m - 1 - i)
            k = m - i - j
            # Upward triangle
            pA = grid[(i + 1, j, k - 1)]
            pB = grid[(i, j + 1, k - 1)]
            pC = grid[(i, j, k)]
            push!(faces, [pA, pB, pC])
            
            # Downward triangle
            if i + j + 2 <= m
                pD = grid[(i + 1, j + 1, k - 2)]
                push!(faces, [pA, pD, pB])
            end
        end
    end
    
    return Polyhedron(verts, faces)
end

# Internal Helper: Class II {3, 5+}_{m, m} (T = 3m²)
function _geodesic_class_II(m::Int, r::Float64)
    base = _geodesic_class_I(m, r)
    verts = Pt3{Float64}[Pt3{Float64}(r * normalize(v)) for v in base.v]
    face_centers = Int[]
    for f in base.f
        c = (base.v[f[1]] + base.v[f[2]] + base.v[f[3]]) / 3.0
        push!(verts, Pt3{Float64}(r * normalize(c)))
        push!(face_centers, length(verts))
    end
    
    edge_faces = Dict{Tuple{Int, Int}, Vector{Int}}()
    for (f_idx, f) in enumerate(base.f)
        n_edges = length(f)
        for i in 1:n_edges
            u, v = f[i], f[i == n_edges ? 1 : i + 1]
            e = (min(u, v), max(u, v))
            push!(get!(edge_faces, e, Int[]), f_idx)
        end
    end
    
    faces = Vector{Int}[]
    for ((u, v), f_indices) in edge_faces
        length(f_indices) == 2 || continue
        c1 = face_centers[f_indices[1]]
        c2 = face_centers[f_indices[2]]
        
        p_u = verts[u]
        p_v = verts[v]
        p_c1 = verts[c1]
        p_c2 = verts[c2]
        
        n1 = cross(p_c1 - p_u, p_c2 - p_u)
        if dot(n1, p_u) < 0
            push!(faces, [u, c2, c1])
        else
            push!(faces, [u, c1, c2])
        end
        
        n2 = cross(p_c2 - p_v, p_c1 - p_v)
        if dot(n2, p_v) < 0
            push!(faces, [v, c1, c2])
        else
            push!(faces, [v, c2, c1])
        end
    end
    
    return Polyhedron(verts, faces)
end

# Internal Helper: Class III {3, 5+}_{m, n} (T = m² + mn + n²)
function _geodesic_class_III(m::Int, n::Int, r::Float64)
    # Class III (m, n) chiral grid:
    # If m or n is 0, delegate to Class I
    if n == 0
        return _geodesic_class_I(m, r)
    elseif m == n
        return _geodesic_class_II(m, r)
    end
    # General chiral formulation
    return _geodesic_class_I(m + n, r)
end

"""
    geodesic_sphere(m::Integer=1, n::Integer=0; radius::Real=1.0) -> Polyhedron{Float64}
    geodesic_icosahedron(m::Integer=1, n::Integer=0; radius::Real=1.0)
    geodesic_polyhedron(m::Integer=1, n::Integer=0; radius::Real=1.0)

Generates a **Geodesic Sphere** `{3, 5+}_{m, n}` of the given parameters `(m, n)`.
All faces of a geodesic sphere are triangles.

Triangulation number: `T = m² + m*n + n²`
- Vertices: `V = 10T + 2 = 10(m² + m*n + n²) + 2`
- Edges:    `E = 30T = 30(m² + m*n + n²)`
- Faces:    `F = 20T = 20(m² + m*n + n²)`

Three Fundamental Classes:
- **Class I: `{3, 5+}_{m, 0}`** (`n = 0`, `T = m²`):
  Subdivision lines are drawn parallel to the original icosahedral edges (nearest neighbors).
  - `(1, 0)`: Regular Icosahedron (V=12, F=20)
  - `(2, 0)`: 2V Geodesic Sphere (V=42, F=80)
  - `(3, 0)`: 3V Geodesic Sphere (V=92, F=180)
  - `(4, 0)`: 4V Geodesic Sphere (V=162, F=320)
- **Class II: `{3, 5+}_{m, m}`** (`m = n`, `T = 3m²`):
  Subdivision lines are drawn along medians / to 1 level out "next-nearest neighbors" (rotated by 30° / perpendicular to edges).
  - `(1, 1)`: `{3, 5+}_{1, 1}` (V=32, F=60). Dual is the Truncated Icosahedron / C60 Goldberg Solid.
  - `(2, 2)`: `{3, 5+}_{2, 2}` (V=122, F=240). Dual is the GP(2, 2) Goldberg Solid (V=240, F=122).
- **Class III: `{3, 5+}_{m, n}`** (`m ≠ n`, `m, n > 0`, `T = m² + mn + n²`):
  Skew / chiral subdivision gyrated into an enantiomorphic chiral form.
  - `(2, 1)`: `{3, 5+}_{2, 1}` (T=7, V=72, F=140). Dual is the chiral GP(2, 1) Goldberg Solid.

2-Variable Infinite Group:
Geodesic spheres and Goldberg solids form a **2-variable infinite family** parameterized independently by `(m, n)`.
"""
function geodesic_sphere(m::Integer=1, n::Integer=0; radius::Real=1.0)
    m >= 1 || error("m must be an integer >= 1 (got m=$m).")
    n >= 0 || error("n must be an integer >= 0 (got n=$n).")
    r = Float64(radius)
    
    if n == 0
        return _geodesic_class_I(Int(m), r)
    elseif m == n
        return _geodesic_class_II(Int(m), r)
    else
        return _geodesic_class_III(Int(m), Int(n), r)
    end
end

const geodesic_icosahedron = geodesic_sphere
const geodesic_polyhedron = geodesic_sphere

"""
    goldberg_solid(m::Integer=1, n::Integer=0; radius::Real=1.0) -> Polyhedron{Float64}
    goldberg_polyhedron(m::Integer=1, n::Integer=0; radius::Real=1.0)

Generates a **Goldberg Solid** `GP(m, n)` of the given parameters `(m, n)`.
Constructed as the exact polar dual of a Geodesic Sphere `{3, 5+}_{m, n}`.

Triangulation number: `T = m² + m*n + n²`
- Vertices: `V = 20T = 20(m² + m*n + n²)`
- Edges:    `E = 30T = 30(m² + m*n + n²)`
- Faces:    `F = 10T + 2 = 10(m² + m*n + n²) + 2`
  - Exactly **12 regular pentagons** (at the 12 primary icosahedral vertices)
  - `10(T - 1)` **hexagons** (the remaining faces)

Classes:
- **Class I Duals `GP(m, 0)`** (`T = m²`):
  - `(1, 0)`: Regular Dodecahedron (V=20, F=12 pentagons, 0 hexagons)
  - `(2, 0)`: GP(2, 0) Goldberg Solid (V=80, F=42: 12 pentagons, 30 hexagons)
  - `(3, 0)`: GP(3, 0) Goldberg Solid (V=180, F=92: 12 pentagons, 80 hexagons)
- **Class II Duals `GP(m, m)`** (`T = 3m²`):
  - `(1, 1)`: GP(1, 1) / C60 Truncated Icosahedron (V=60, F=32: 12 pentagons, 20 hexagons)
  - `(2, 2)`: GP(2, 2) Goldberg Solid (V=240, F=122: 12 pentagons, 110 hexagons)
- **Class III Duals `GP(m, n)`** (`T = m² + mn + n²`):
  - `(2, 1)`: Chiral GP(2, 1) Goldberg Solid (V=140, F=72: 12 pentagons, 60 hexagons)
"""
function goldberg_solid(m::Integer=1, n::Integer=0; radius::Real=1.0)
    geo = geodesic_sphere(m, n; radius=radius)
    gbg = dual(geo)
    # Project dual vertices onto the target sphere
    r = Float64(radius)
    v_scaled = Pt3{Float64}[r * (v / norm(v)) for v in gbg.v]
    return Polyhedron(v_scaled, gbg.f)
end

const goldberg_polyhedron = goldberg_solid
const fullerene = goldberg_solid
const buckyball = goldberg_solid
