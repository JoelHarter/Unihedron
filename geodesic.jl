# Geodesic Spheres and Buckyball / Fullerene / Goldberg Polyhedra Generators

using StaticArrays
using LinearAlgebra

"""
    geodesic_sphere(frequency::Integer=1; radius::Real=1.0) -> Polyhedron{Float64}
    geodesic_icosahedron(frequency::Integer=1; radius::Real=1.0)

Generates a Geodesic Sphere of the given breakdown frequency / degree `frequency` (ν).
Subdivides each of the 20 triangular faces of a regular icosahedron into `ν²` smaller triangles,
and normalizes all vertices onto a sphere of radius `radius`.

- Frequency 1: Regular Icosahedron (V=12, F=20)
- Frequency 2: 2V Geodesic Sphere (V=42, F=80)
- Frequency 3: 3V Geodesic Sphere (V=92, F=180)
- Frequency 4: 4V Geodesic Sphere (V=162, F=320)
- Frequency ν: (V = 10ν² + 2, F = 20ν²)
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
const honeyball = geodesic_sphere
const honeycomb_ball = geodesic_sphere

"""
    buckyball(degree::Integer=1; radius::Real=1.0) -> Polyhedron{Float64}
    buckyball(m::Integer, n::Integer; radius::Real=1.0)
    fullerene(degree::Integer=1; radius::Real=1.0)
    goldberg_polyhedron(degree::Integer=1; radius::Real=1.0)

Generates a Buckyball (Goldberg Polyhedron / Fullerene) of the given degree `degree` (or frequency ν).
Constructed as the exact polar dual of a Geodesic Sphere of frequency `degree`.

Structure:
- Every Buckyball has **exactly 12 regular pentagons** (located at the 12 original icosahedron vertices)
  and `10(degree² - 1)` **hexagons**.
- Degree 1: Regular Dodecahedron (V=20, F=12 pentagons, 0 hexagons)
- Degree 2: C₈₀ Fullerene (V=80, F=42: 12 pentagons, 30 hexagons)
- Degree 3: C₁₈₀ Fullerene (V=180, F=92: 12 pentagons, 80 hexagons)
- Degree 4: C₃₂₀ Fullerene (V=320, F=162: 12 pentagons, 150 hexagons)
- Degree ν: (V = 20ν², F = 10ν² + 2)
"""
function buckyball(degree::Integer=1; radius::Real=1.0)
    geo = geodesic_sphere(degree; radius=radius)
    bky = dual(geo)
    # Project dual vertices onto the target sphere
    r = Float64(radius)
    v_scaled = Pt3{Float64}[r * (v / norm(v)) for v in bky.v]
    return Polyhedron(v_scaled, bky.f)
end

const fullerene = buckyball
const goldberg_polyhedron = buckyball
