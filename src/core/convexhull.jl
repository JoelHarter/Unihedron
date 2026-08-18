using QHull
using StaticArrays

"""
    convex_hull(pts::AbstractVector{<:SVector{2, T}}) where T
    convex_hull(pts::AbstractVector{<:SVector{3, T}}) where T
    convex_hull(pts::Tuple)

Unified 2D and 3D convex hull function:
- **2D**: Uses a pure Julia Monotone Chain (Graham Scan variant) algorithm (fast, zero C/Python dependencies). Returns `Vector{Pt2{T}}`.
- **3D**: Uses `QHull.chull` (the gold standard 3D spatial C library wrapper). Returns a `Polyhedron{T}` mesh.
"""
function convex_hull(pts::AbstractVector{<:SVector{2, T}}) where T
    n = length(pts)
    n <= 3 && return Pt2{T}[Pt2{T}(p[1], p[2]) for p in pts]

    # Monotone Chain 2D algorithm
    sp = sort(pts, by = p -> (p[1], p[2]))
    cross2d(o, a, b) = (a[1] - o[1]) * (b[2] - o[2]) - (a[2] - o[2]) * (b[1] - o[1])

    lower = Pt2{T}[]
    for p in sp
        while length(lower) >= 2 && cross2d(lower[end-1], lower[end], p) <= 0
            pop!(lower)
        end
        push!(lower, p)
    end

    upper = Pt2{T}[]
    for p in reverse(sp)
        while length(upper) >= 2 && cross2d(upper[end-1], upper[end], p) <= 0
            pop!(upper)
        end
        push!(upper, p)
    end

    return vcat(lower[1:end-1], upper[1:end-1])
end

function convex_hull(pts::AbstractVector{<:SVector{3, T}}; merge_coplanar::Bool=false, atol::Float64=1e-6) where T
    n = length(pts)
    n < 4 && error("3D Convex hull requires at least 4 non-coplanar points.")

    mat = Matrix(stack(pts; dims=1))
    ch = chull(mat)
    
    simplices = Vector{Int}[Vector{Int}(row) for row in eachrow(ch.simplices)]
    raw_poly = Polyhedron(pts, simplices)
    
    if !merge_coplanar
        return raw_poly
    end
    
    return sew_coplanar_faces(raw_poly; atol=atol)
end

# Convenience overloads for Tuples or splatted SVectors
convex_hull(pts::Tuple; kwargs...) = convex_hull(collect(pts); kwargs...)
convex_hull(pts::SVector...; kwargs...) = convex_hull(collect(pts); kwargs...)

