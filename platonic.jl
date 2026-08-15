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
    ϕ = (1.0 + sqrt(5.0)) / 2.0
    inv_ϕ = 1.0 / ϕ
    
    v = [
        # Cube vertices
        Pt3{Float64}(-1.0, -1.0, -1.0), Pt3{Float64}( 1.0, -1.0, -1.0),
        Pt3{Float64}( 1.0,  1.0, -1.0), Pt3{Float64}(-1.0,  1.0, -1.0),
        Pt3{Float64}(-1.0, -1.0,  1.0), Pt3{Float64}( 1.0, -1.0,  1.0),
        Pt3{Float64}( 1.0,  1.0,  1.0), Pt3{Float64}(-1.0,  1.0,  1.0),
        # (0, ±1/ϕ, ±ϕ)
        Pt3{Float64}(0.0, -inv_ϕ, -ϕ), Pt3{Float64}(0.0,  inv_ϕ, -ϕ),
        Pt3{Float64}(0.0, -inv_ϕ,  ϕ), Pt3{Float64}(0.0,  inv_ϕ,  ϕ),
        # (±1/ϕ, ±ϕ, 0)
        Pt3{Float64}(-inv_ϕ, -ϕ, 0.0), Pt3{Float64}( inv_ϕ, -ϕ, 0.0),
        Pt3{Float64}(-inv_ϕ,  ϕ, 0.0), Pt3{Float64}( inv_ϕ,  ϕ, 0.0),
        # (±ϕ, 0, ±1/ϕ)
        Pt3{Float64}(-ϕ, 0.0, -inv_ϕ), Pt3{Float64}(-ϕ, 0.0,  inv_ϕ),
        Pt3{Float64}( ϕ, 0.0, -inv_ϕ), Pt3{Float64}( ϕ, 0.0,  inv_ϕ)
    ]
    
    f = [
        [3, 16, 4, 10, 9],   # Top-ish face 1
        [16, 7, 20, 19, 3],  # Top-ish face 2
        [7, 12, 8, 15, 16],  # Front-ish top
        [12, 11, 5, 18, 8],  # Front
        [11, 6, 20, 7, 12],  # Right front
        [6, 14, 13, 5, 11],  # Bottom front
        [14, 2, 19, 20, 6],  # Bottom right
        [2, 9, 10, 1, 13],   # Back bottom
        [1, 17, 18, 5, 13],  # Left bottom
        [18, 8, 15, 4, 17],  # Left top
        [4, 10, 9, 1, 17],   # Back left
        [19, 2, 14, 13, 9]   # Bottom back
    ]
    return Polyhedron(v, f)
end
