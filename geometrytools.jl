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
            if allow_flipped && all(isapprox.(norm_c₁, conj.(norm_c₂); atol=1e-8))
                aligned_p₂_2d = [Pt2{Float64}(p[1], -p[2]) for p in circshift(p₂_2d, 1 - i)]
                return (true, scale, true, p₁_2d, aligned_p₂_2d)
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
                if all(isapprox.(norm_c₁, conj.(norm_c₂_rev); atol=1e-8))
                    aligned_p₂_2d = [Pt2{Float64}(p[1], -p[2]) for p in [p₂_2d[mod1(i - k + 1, n)] for k in 1:n]]
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
    sew_coplanar_faces(P::Polyhedron{T}; atol::Float64=1e-6) where T
    merge_coplanar_faces(P::Polyhedron; atol=1e-6)
    sew_faces(P::Polyhedron; atol=1e-6)

Finds all adjacent (bordering) coplanar faces in a polyhedron and sews them together into single `n`-gon faces.
Useful for converting raw triangulated meshes (e.g. from `convex_hull(pts; merge_coplanar=false)`) into polyhedra with combined regular/irregular polygon faces (e.g. recovering the 12 regular pentagons of a dodecahedron from 36 triangles).
"""
function sew_coplanar_faces(P::Polyhedron{T}; atol::Float64=1e-6) where T
    n_faces = length(P)
    n_faces <= 1 && return P
    
    # 1. Compute face normals and plane offsets relative to centroid
    poly_center = sum(P.v) / length(P.v)
    normals = Pt3{Float64}[]
    offsets = Float64[]
    
    for k in 1:n_faces
        pts = [P.v[i] for i in P.f[k]]
        nv = face_normal(pts)
        c = centroid(pts)
        if (c - poly_center) ⋅ nv < 0
            nv = -nv
        end
        push!(normals, nv)
        push!(offsets, c ⋅ nv)
    end
    
    # 2. Build map from undirected edge -> incident face indices
    edge_to_faces = Dict{Tuple{Int, Int}, Vector{Int}}()
    for (f_idx, face) in enumerate(P.f)
        n = length(face)
        for i in 1:n
            u = face[i]
            v = face[i == n ? 1 : i + 1]
            key = (min(u, v), max(u, v))
            push!(get!(edge_to_faces, key, Int[]), f_idx)
        end
    end
    
    # Build adjacency graph for bordering coplanar faces
    adj = [Int[] for _ in 1:n_faces]
    for (edge, incident) in edge_to_faces
        if length(incident) == 2
            f1, f2 = incident[1], incident[2]
            if isapprox(normals[f1], normals[f2]; atol=atol) && isapprox(offsets[f1], offsets[f2]; atol=atol)
                push!(adj[f1], f2)
                push!(adj[f2], f1)
            end
        end
    end
    
    # 3. Find connected components of bordering coplanar faces
    visited = falses(n_faces)
    merged_faces = Vector{Int}[]
    
    for start_f in 1:n_faces
        visited[start_f] && continue
        
        group = Int[]
        queue = Int[start_f]
        visited[start_f] = true
        
        while !isempty(queue)
            curr = popfirst!(queue)
            push!(group, curr)
            for neighbor in adj[curr]
                if !visited[neighbor]
                    visited[neighbor] = true
                    push!(queue, neighbor)
                end
            end
        end
        
        if length(group) == 1
            push!(merged_faces, P.f[start_f])
            continue
        end
        
        # Merge faces in group by cancelling shared interior edges
        ref_n = normals[start_f]
        edge_counts = Dict{Tuple{Int, Int}, Int}()
        
        for f_idx in group
            face = P.f[f_idx]
            pts = [P.v[i] for i in face]
            tri_n = face_normal(pts)
            ordered_face = (tri_n ⋅ ref_n < 0) ? reverse(face) : face
            n = length(ordered_face)
            for k in 1:n
                u = ordered_face[k]
                v = ordered_face[k == n ? 1 : k + 1]
                edge_counts[(u, v)] = get(edge_counts, (u, v), 0) + 1
            end
        end
        
        # Boundary edges are those whose reverse directed edge does not appear
        boundary_next = Dict{Int, Int}()
        for ((u, v), cnt) in edge_counts
            if get(edge_counts, (v, u), 0) == 0
                boundary_next[u] = v
            end
        end
        
        if isempty(boundary_next)
            push!(merged_faces, P.f[start_f])
            continue
        end
        
        # Traverse directed boundary cycle
        start_v = first(keys(boundary_next))
        cycle = [start_v]
        curr = boundary_next[start_v]
        while curr != start_v && length(cycle) <= length(boundary_next)
            push!(cycle, curr)
            curr = get(boundary_next, curr, start_v)
        end
        push!(merged_faces, cycle)
    end
    
    # 4. Clean unused vertices and remap indices
    used_indices = sort(unique(vcat(merged_faces...)))
    index_map = Dict{Int, Int}(old_idx => new_idx for (new_idx, old_idx) in enumerate(used_indices))
    cleaned_v = P.v[used_indices]
    cleaned_f = [[index_map[i] for i in face] for face in merged_faces]
    
    return Polyhedron(cleaned_v, cleaned_f)
end

const merge_coplanar_faces = sew_coplanar_faces
const sew_faces = sew_coplanar_faces

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

# ============================================================================
# Face Congruence Classification
# ============================================================================

"""
    classify_faces(P::Polyhedron; allow_flipped::Bool=true, atol::Real=1e-6) -> Vector{Int}
    congruent_face_types(P::Polyhedron; kwargs...)

Detects unique congruent face types on a `Polyhedron`.
Returns a `Vector{Int}` with one integer per face of `P`, where the integer denotes the
congruent polygon type (1, 2, ..., K).

# Example
```julia
P = truncated_icosahedron() # Buckyball (12 pentagons, 20 hexagons)
types = classify_faces(P)
# Returns a 32-element vector of 1s and 2s
```
"""
function classify_faces(P::Polyhedron; allow_flipped::Bool=true, atol::Real=1e-6)
    F = length(P.f)
    types = zeros(Int, F)
    
    representatives = Vector{Pt3{Float64}}[]
    
    for (i, face) in enumerate(P.f)
        face_pts = [P.v[k] for k in face]
        matched = false
        for (type_idx, rep_pts) in enumerate(representatives)
            res = isCongruent(face_pts, rep_pts; allow_flipped=allow_flipped)
            if res[1]
                types[i] = type_idx
                matched = true
                break
            end
        end
        if !matched
            push!(representatives, face_pts)
            types[i] = length(representatives)
        end
    end
    return types
end

const congruent_face_types = classify_faces
const face_types = classify_faces

"""
    classify_faces_with_handedness(P::Polyhedron; atol::Real=1e-6) -> (Vector{Int}, Vector{Bool})

Classifies all faces of `P` into congruent polygon types (1..K) and detects mirror handedness.
Returns `(types, is_mirror)` where:
- `types[i]` is the integer index (1..K) of the polygon type.
- `is_mirror[i]` is `false` for normal orientation and `true` for a chiral mirror reflection.
"""
function classify_faces_with_handedness(P::Polyhedron; atol::Real=1e-6)
    F = length(P.f)
    types = zeros(Int, F)
    is_mirror = zeros(Bool, F)
    representatives = Vector{Pt3{Float64}}[]
    
    for (i, face) in enumerate(P.f)
        face_pts = [P.v[k] for k in face]
        matched = false
        for (type_idx, rep_pts) in enumerate(representatives)
            res = isCongruent(face_pts, rep_pts; allow_flipped=true)
            if res[1]
                types[i] = type_idx
                is_mirror[i] = res[3]
                matched = true
                break
            end
        end
        if !matched
            push!(representatives, face_pts)
            types[i] = length(representatives)
            is_mirror[i] = false
        end
    end
    return types, is_mirror
end

"""
    unique_face_polygons(P::Polyhedron; allow_flipped::Bool=true, flatten_to_2d::Bool=true)

Returns a list of the K unique canonical representative face polygons of `P`.
If `flatten_to_2d=true`, returns `Vector{Vector{Pt2{Float64}}}` (flattened via `Polygon2`).
Otherwise returns `Vector{Vector{Pt3{Float64}}}` in 3D.
"""
function unique_face_polygons(P::Polyhedron; allow_flipped::Bool=true, flatten_to_2d::Bool=true)
    types = classify_faces(P; allow_flipped=allow_flipped)
    K = maximum(types)
    reps = Vector{Vector{Pt3{Float64}}}(undef, K)
    
    for (i, t) in enumerate(types)
        if !isassigned(reps, t)
            reps[t] = [P.v[k] for k in P.f[i]]
        end
    end
    
    if flatten_to_2d
        return [Polygon2(rep) for rep in reps]
    else
        return reps
    end
end

"""
    face_type_counts(P::Polyhedron; allow_flipped::Bool=true) -> Dict{Int, Int}

Returns a dictionary mapping each congruent polygon type (1, 2, ..., K) to the number of faces of that type.
"""
function face_type_counts(P::Polyhedron; allow_flipped::Bool=true)
    types = classify_faces(P; allow_flipped=allow_flipped)
    counts = Dict{Int, Int}()
    for t in types
        counts[t] = get(counts, t, 0) + 1
    end
    return counts
end