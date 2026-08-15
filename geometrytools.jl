using LinearAlgebra
using StaticArrays

# Helper views
backwards(P) = @view P[end:-1:1]
increment(P) = @view P[vcat(2:end, 1)]

"""
    Polygon2(P::AbstractVector{<:SVector{N, T}}) where {N, T}
    Polygon2(P::Tuple)

Projects a 3D polygon onto its local 2D plane, returning a vector of 2D points (`Pt2{T}`).
If `N == 2`, returns the points converted to `Pt2{T}` directly.
"""
function Polygon2(P::AbstractVector{<:SVector{N, T}}) where {N, T}
    if N == 2
        return Pt2{T}[Pt2{T}(p[1], p[2]) for p in P]
    end

    n_pts = length(P)
    n_pts < 3 && return Pt2{T}[Pt2{T}(0, 0) for _ in P]

    o = P[1]
    
    # 1. First non-zero edge vector for x_axis
    x_axis = Pt3{T}(1, 0, 0)
    for i in 2:n_pts
        x_dir = P[i] - o
        x_len = norm(x_dir)
        if !iszero(x_len)
            x_axis = x_dir / x_len
            break
        end
    end

    # 2. Find plane normal using first non-collinear point
    n_vec = Pt3{T}(0, 0, 0)
    has_plane = false
    for i in 3:n_pts
        cross_prod = x_axis × (P[i] - o)
        cp_len = norm(cross_prod)
        if !iszero(cp_len)
            n_vec = cross_prod / cp_len
            has_plane = true
            break
        end
    end

    # 3. Y-axis orthogonal to x-axis and plane normal
    if !has_plane
        y_axis = abs(x_axis[1]) < 0.9 ? Pt3{T}(1, 0, 0) × x_axis : Pt3{T}(0, 1, 0) × x_axis
        y_axis = y_axis / norm(y_axis)
    else
        y_axis = n_vec × x_axis
    end

    # 4. Local 2D coordinates via dot product projections
    return Pt2{T}[Pt2{T}((p - o) ⋅ x_axis, (p - o) ⋅ y_axis) for p in P]
end

Polygon2(P::Tuple) = Polygon2(collect(P))
Polygon2(P::SVector...) = Polygon2(collect(P))

"""
    center_of_mass(P::AbstractVector{<:SVector})
    centroid(P)

Compute the mean position (centroid) of a list of points.
"""
function center_of_mass(P::AbstractVector{<:SVector{N, T}}) where {N, T}
    isempty(P) && error("Cannot compute center of mass of an empty point set.")
    return sum(P) / length(P)
end

const centroid = center_of_mass

"""
    face_normal(v₁::SVector{3}, v₂::SVector{3}, v₃::SVector{3}; normalize_vector::Bool=true)
    face_normal(F::AbstractVector{<:SVector{3}}; normalize_vector::Bool=true)

Compute the normal vector of a 3D face.
"""
function face_normal(v₁::SVector{3, T}, v₂::SVector{3, T}, v₃::SVector{3, T}; normalize_vector::Bool=true) where T
    n = (v₂ - v₁) × (v₃ - v₁)
    if normalize_vector
        len = norm(n)
        return len > 0 ? n / len : n
    end
    return n
end

function face_normal(F::AbstractVector{<:SVector{3, T}}; normalize_vector::Bool=true) where T
    length(F) < 3 && error("Face must have at least 3 vertices to compute normal.")
    return face_normal(F[1], F[2], F[3]; normalize_vector=normalize_vector)
end

"""
    isBordering(F₁::AbstractVector{<:SVector}, F₂::AbstractVector{<:SVector}; allow_flipped::Bool = false)

Check if two faces share an edge. If so, return `(true, aligned_F₁, aligned_F₂)`.
By default `allow_flipped=false` skips checking flipped/opposite-direction edges.
"""
function isBordering(F₁::AbstractVector{SVector{N, T}}, 
                     F₂::AbstractVector{SVector{N, T}}; 
                     allow_flipped::Bool = false) where {N, T}
    n₁ = length(F₁)
    n₂ = length(F₂)
    
    for i in 1:n₁
        v₁ = F₁[i]
        v₂ = F₁[i == n₁ ? 1 : i + 1] 
        
        for j in 1:n₂
            u₁ = F₂[j]
            u₂ = F₂[j == n₂ ? 1 : j + 1]
            
            # Match in same direction
            if v₁ ≈ u₁ && v₂ ≈ u₂
                aligned_F₁ = circshift(F₁, 1 - i)
                aligned_F₂ = circshift(F₂, 1 - j)
                return (true, aligned_F₁, aligned_F₂)
            end
            
            # Match in opposite direction (flipped edge)
            if allow_flipped && (v₁ ≈ u₂ && v₂ ≈ u₁)
                aligned_F₁ = circshift(F₁, 1 - i)
                aligned_F₂ = circshift(reverse(circshift(F₂, 1 - j)), 2)
                return (true, aligned_F₁, aligned_F₂)
            end
        end
    end
    
    return (false, collect(F₁), collect(F₂))
end

"""
    isCoplanar(F₁::AbstractVector{<:SVector{3}}, F₂::AbstractVector{<:SVector{3}}; atol=1e-8)

Check if two 3D faces lie in the same plane.
"""
function isCoplanar(F₁::AbstractVector{SVector{3, T}}, F₂::AbstractVector{SVector{3, T}}; atol=1e-8) where T
    length(F₁) < 3 && return true
    
    anchor = F₁[1]
    x_dir = F₁[2] - anchor
    u = Pt3{T}(0, 0, 0)
    found_plane = false
    
    for i in 3:length(F₁)
        cp = x_dir × (F₁[i] - anchor)
        if norm(cp) > atol
            u = cp / norm(cp)
            found_plane = true
            break
        end
    end
    
    if !found_plane
        dir = norm(x_dir) > atol ? x_dir / norm(x_dir) : Pt3{T}(1, 0, 0)
        for p in F₁
            norm((p - anchor) × dir) > atol && return false
        end
        for p in F₂
            norm((p - anchor) × dir) > atol && return false
        end
        return true
    end

    for p in @view F₁[4:end]
        isapprox((p - anchor) ⋅ u, 0.0; atol=atol) || return false
    end

    for p in F₂
        isapprox((p - anchor) ⋅ u, 0.0; atol=atol) || return false
    end

    return true
end

"""
    isSimilar(P₁, P₂; allow_scaling=true, allow_flipped=false)

Determines if two 2D/3D polygons are geometrically similar.
Uses `Polygon2` to flatten 3D polygons to 2D.
"""
function isSimilar(P₁::AbstractVector{SVector{N₁, T₁}}, 
                   P₂::AbstractVector{SVector{N₂, T₂}}; 
                   allow_scaling::Bool = true, 
                   allow_flipped::Bool = false) where {N₁, T₁, N₂, T₂}
    
    n = length(P₁)
    dummy_pts = SVector{2, Float64}[]
    fail_return = (false, 0.0, false, dummy_pts, dummy_pts)
    
    if length(P₂) != n
        return fail_return
    end

    p₁_2d = Polygon2(P₁)
    p₂_2d = Polygon2(P₂)
    
    c₁ = [complex(p[1], p[2]) for p in p₁_2d]
    c₂ = [complex(p[1], p[2]) for p in p₂_2d]
    
    edge₁_len = abs(c₁[2] - c₁[1])
    norm_c₁ = (c₁ .- c₁[1]) ./ (c₁[2] - c₁[1])

    for i in 1:n
        next_i = (i == n) ? 1 : i + 1
        edge₂_len = abs(c₂[next_i] - c₂[i])
        scale = edge₂_len / edge₁_len
        
        if allow_scaling || isapprox(scale, 1.0; atol=1e-8)
            shift_c₂ = circshift(c₂, 1 - i)
            norm_c₂ = (shift_c₂ .- shift_c₂[1]) ./ (shift_c₂[2] - shift_c₂[1])
            
            if all(isapprox.(norm_c₁, norm_c₂; atol=1e-8))
                return (true, scale, false, p₁_2d, circshift(p₂_2d, 1 - i))
            end
        end
        
        if allow_flipped
            prev_i = (i == 1) ? n : i - 1
            edge₂_len_rev = abs(c₂[prev_i] - c₂[i])
            scale_rev = edge₂_len_rev / edge₁_len
            
            if allow_scaling || isapprox(scale_rev, 1.0; atol=1e-8)
                rev_c₂ = [c₂[mod1(i - k + 1, n)] for k in 1:n]
                norm_c₂_rev = (rev_c₂ .- rev_c₂[1]) ./ (rev_c₂[2] - rev_c₂[1])
                
                if all(isapprox.(norm_c₁, norm_c₂_rev; atol=1e-8))
                    aligned_p₂_2d = [p₂_2d[mod1(i - k + 1, n)] for k in 1:n]
                    return (true, scale_rev, true, p₁_2d, aligned_p₂_2d)
                end
            end
        end
    end

    return fail_return
end

"""
    isCongruent(P₁, P₂; allow_flipped=false)

Checks if two polygons are congruent (same size and shape).
"""
function isCongruent(P₁::AbstractVector{SVector{N₁, T₁}}, 
                    P₂::AbstractVector{SVector{N₂, T₂}}; 
                    allow_flipped::Bool = false) where {N₁, T₁, N₂, T₂}
    return isSimilar(P₁, P₂; allow_scaling=false, allow_flipped=allow_flipped)
end

"""
    dual(P::Polyhedron{T}; polar::Bool=true) where T

Computes the dual polyhedron of `P`.
- **Vertices**: Each dual vertex corresponds to a primal face. If `polar=true` and the origin is in the interior, polar reciprocation ``v^* = n / (c \\cdot n)`` is used, ensuring exact face planarity for regular and semi-regular solids. If `polar=false`, face centroids are used directly.
- **Faces**: Each dual face corresponds to a primal vertex, ordered cyclically around the primal vertex.
"""
function dual(P::Polyhedron{T}; polar::Bool=true) where T
    n_faces = length(P)
    n_verts = length(P.v)
    
    # 1. Dual vertices from primal faces
    dual_verts = Pt3{Float64}[]
    for k in 1:n_faces
        c = centroid(P[k])
        n = face_normal(P[k])
        d = c ⋅ n
        if polar && abs(d) > 1e-12
            push!(dual_verts, Pt3{Float64}(n / d))
        else
            push!(dual_verts, Pt3{Float64}(c))
        end
    end
    
    # 2. Directed half-edge map: (u, v) -> face index
    edge_to_face = Dict{Tuple{Int, Int}, Int}()
    for (f_idx, face) in enumerate(P.f)
        n = length(face)
        for i in 1:n
            u = face[i]
            v = face[i == n ? 1 : i + 1]
            edge_to_face[(u, v)] = f_idx
        end
    end
    
    # 3. For each primal vertex, order incident faces cyclically
    dual_faces = Vector{Int}[]
    for v_idx in 1:n_verts
        incident_faces = [k for k in 1:n_faces if v_idx in P.f[k]]
        isempty(incident_faces) && continue
        
        f_start = incident_faces[1]
        ordered_face_indices = Int[f_start]
        
        face_verts = P.f[f_start]
        pos = findfirst(==(v_idx), face_verts)
        u = face_verts[pos == length(face_verts) ? 1 : pos + 1]
        
        curr_f = f_start
        curr_u = u
        
        while true
            next_f = get(edge_to_face, (curr_u, v_idx), 0)
            if next_f == 0 || next_f == f_start
                break
            end
            push!(ordered_face_indices, next_f)
            
            next_face_verts = P.f[next_f]
            pos_next = findfirst(==(v_idx), next_face_verts)
            curr_u = next_face_verts[pos_next == length(next_face_verts) ? 1 : pos_next + 1]
            curr_f = next_f
            
            if length(ordered_face_indices) > length(incident_faces) + 2
                break
            end
        end
        
        if length(ordered_face_indices) != length(incident_faces)
            ordered_face_indices = incident_faces
        end
        
        push!(dual_faces, ordered_face_indices)
    end
    
    return Polyhedron(dual_verts, dual_faces)
end