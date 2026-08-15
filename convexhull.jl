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
    
    if !merge_coplanar
        return Polyhedron(pts, simplices)
    end
    
    # Merge coplanar facets into n-gons
    facet_normals = Pt3{Float64}[]
    facet_d = Float64[]
    for s in simplices
        v1, v2, v3 = pts[s[1]], pts[s[2]], pts[s[3]]
        nv = (v2 - v1) × (v3 - v1)
        len = norm(nv)
        nv = len > 0 ? nv / len : nv
        c = (v1 + v2 + v3) / 3
        if c ⋅ nv < 0
            nv = -nv
        end
        push!(facet_normals, nv)
        push!(facet_d, c ⋅ nv)
    end
    
    visited = falses(length(simplices))
    merged_faces = Vector{Int}[]
    
    for i in 1:length(simplices)
        visited[i] && continue
        visited[i] = true
        
        group = [i]
        n_i = facet_normals[i]
        d_i = facet_d[i]
        
        for j in (i+1):length(simplices)
            if !visited[j]
                n_j = facet_normals[j]
                d_j = facet_d[j]
                if isapprox(n_i, n_j; atol=atol) && isapprox(d_i, d_j; atol=atol)
                    visited[j] = true
                    push!(group, j)
                end
            end
        end
        
        edge_counts = Dict{Tuple{Int, Int}, Int}()
        for f_idx in group
            s = simplices[f_idx]
            v1, v2, v3 = pts[s[1]], pts[s[2]], pts[s[3]]
            tri_n = (v2 - v1) × (v3 - v1)
            if tri_n ⋅ n_i < 0
                s = [s[1], s[3], s[2]]
            end
            for k in 1:3
                u = s[k]
                v = s[k == 3 ? 1 : k + 1]
                edge_counts[(u, v)] = get(edge_counts, (u, v), 0) + 1
            end
        end
        
        boundary_next = Dict{Int, Int}()
        for ((u, v), cnt) in edge_counts
            if get(edge_counts, (v, u), 0) == 0
                boundary_next[u] = v
            end
        end
        
        isempty(boundary_next) && continue
        start_v = first(keys(boundary_next))
        cycle = [start_v]
        curr = boundary_next[start_v]
        while curr != start_v && length(cycle) <= length(boundary_next)
            push!(cycle, curr)
            curr = get(boundary_next, curr, start_v)
        end
        push!(merged_faces, cycle)
    end
    
    return Polyhedron(pts, merged_faces)
end

# Convenience overloads for Tuples or splatted SVectors
convex_hull(pts::Tuple; kwargs...) = convex_hull(collect(pts); kwargs...)
convex_hull(pts::SVector...; kwargs...) = convex_hull(collect(pts); kwargs...)

