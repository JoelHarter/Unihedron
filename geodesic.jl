# Geodesic Spheres (Triangular) and Goldberg Solids (Pentagonal/Hexagonal) Generators

using StaticArrays
using LinearAlgebra

"""
    geodesic_sphere(frequency::Integer=1; radius::Real=1.0) -> Polyhedron{Float64}
    geodesic_icosahedron(frequency::Integer=1; radius::Real=1.0)
    geodesic_polyhedron(frequency::Integer=1; radius::Real=1.0)

Generates a **Geodesic Sphere** of the given breakdown frequency `frequency` (ν).
Subdivides each of the 20 triangular faces of a regular icosahedron into `ν²` smaller equilateral triangles,
and normalizes all vertices onto a sphere of radius `radius`. All faces of a geodesic sphere are triangles.

- Frequency 1: Regular Icosahedron (V=12, F=20 triangles)
- Frequency 2: 2V Geodesic Sphere (V=42, F=80 triangles)
- Frequency 3: 3V Geodesic Sphere (V=92, F=180 triangles)
- Frequency 4: 4V Geodesic Sphere (V=162, F=320 triangles)
- Frequency ν: (V = 10ν² + 2, F = 20ν² triangles)
"""
function geodesic_sphere(frequency::Integer=1; radius::Real=1.0)
    nu = frequency
    nu >= 1 || error("Frequency must be an integer >= 1 (got frequency=$nu).")
    
    ico = icosahedron()
    r = Float64(radius)
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
        for i in 0:nu, j in 0:(nu - i)
            k = nu - i - j
            p_bary = (i * v1 + j * v2 + k * v3) / nu
            grid[(i, j, k)] = get_or_add_vertex(p_bary)
        end
        
        # Sub-triangles
        for i in 0:(nu - 1), j in 0:(nu - 1 - i)
            k = nu - i - j
            # Upward triangle
            pA = grid[(i + 1, j, k - 1)]
            pB = grid[(i, j + 1, k - 1)]
            pC = grid[(i, j, k)]
            push!(faces, [pA, pB, pC])
            
            # Downward triangle
            if i + j + 2 <= nu
                pD = grid[(i + 1, j + 1, k - 2)]
                push!(faces, [pA, pD, pB])
            end
        end
    end
    
    return Polyhedron(verts, faces)
end

const geodesic_icosahedron = geodesic_sphere
const geodesic_polyhedron = geodesic_sphere

"""
    goldberg_solid(degree::Integer=1; radius::Real=1.0) -> Polyhedron{Float64}
    goldberg_polyhedron(degree::Integer=1; radius::Real=1.0)

Generates a **Goldberg Solid** of the given degree `degree` (frequency ν).
Constructed as the exact polar dual of a Geodesic Sphere of frequency `degree`.

Structure:
- Every Goldberg Solid has **exactly 12 pentagons** (located at the 12 vertices of the dual icosahedron)
  and `10(degree² - 1)` **hexagons** (the remaining faces).
- Degree 1: Regular Dodecahedron (V=20, F=12 pentagons, 0 hexagons)
- Degree 2: GP(2, 0) Goldberg Solid (V=80, F=42: 12 pentagons, 30 hexagons)
- Degree 3: GP(3, 0) Goldberg Solid (V=180, F=92: 12 pentagons, 80 hexagons)
- Degree 4: GP(4, 0) Goldberg Solid (V=320, F=162: 12 pentagons, 150 hexagons)
- Degree ν: (V = 20ν², F = 10ν² + 2: 12 pentagons, 10(ν² - 1) hexagons)
"""
function goldberg_solid(degree::Integer=1; radius::Real=1.0)
    geo = geodesic_sphere(degree; radius=radius)
    gbg = dual(geo)
    # Project dual vertices onto the target sphere
    r = Float64(radius)
    v_scaled = Pt3{Float64}[r * (v / norm(v)) for v in gbg.v]
    return Polyhedron(v_scaled, gbg.f)
end

const goldberg_polyhedron = goldberg_solid
const fullerene = goldberg_solid
const buckyball = goldberg_solid
