# Constructive Geometric Operations for Polyhedra & Johnson Solids
# Implements cupolae, rotundae, elongation, gyroelongation, augmentation, diminution, and gyration.

"""
    cupola(n::Integer; s::Real=1.0)

Constructs an `n`-gonal cupola (`n ∈ {3, 4, 5}`).
- `n=3`: Triangular cupola (Johnson solid J₃, V=9, F=8)
- `n=4`: Square cupola (Johnson solid J₄, V=12, F=10)
- `n=5`: Pentagonal cupola (Johnson solid J₅, V=15, F=12)
"""
function cupola(n::Integer; s::Real=1.0)
    (3 <= n <= 5) || error("Cupola only forms convex regular-faced polyhedra for n ∈ {3, 4, 5}, got n = $n.")
    r_top = s / (2 * sin(π / n))
    r_bot = s / (2 * sin(π / (2n)))
    h = sqrt(s^2 - r_top^2)
    
    v = Pt3{Float64}[]
    # Bottom 2n-gon at z = -h/2
    for k in 0:(2n-1)
        θ = 2π * (k + 0.5) / (2n)
        push!(v, Pt3{Float64}(r_bot * cos(θ), r_bot * sin(θ), -h/2))
    end
    # Top n-gon at z = +h/2
    for j in 0:(n-1)
        θ = 2π * j / n
        push!(v, Pt3{Float64}(r_top * cos(θ), r_top * sin(θ), h/2))
    end
    return convex_hull(v; merge_coplanar=true)
end

"""
    rotunda(; s::Real=1.0)
    pentagonal_rotunda(; s::Real=1.0)

Constructs the Pentagonal Rotunda (Johnson solid J₆, V=20, F=17).
Consists of 1 decagonal base, 1 top pentagonal base, 5 pentagonal sides, and 10 triangular sides.
"""
function rotunda(; s::Real=1.0)
    ico = icosidodecahedron()
    for i in 1:length(ico.v), j in (i+1):length(ico.v), k in (j+1):length(ico.v)
        v1, v2, v3 = ico.v[i], ico.v[j], ico.v[k]
        nv = (v2 - v1) × (v3 - v1)
        norm(nv) < 1e-6 && continue
        nv = nv / norm(nv)
        d = v1 ⋅ nv
        on_plane = filter(v -> abs(v ⋅ nv - d) < 1e-5, ico.v)
        if length(on_plane) == 10
            upper_verts = filter(v -> (v ⋅ nv) >= d - 1e-5, ico.v)
            if length(upper_verts) == 20
                rot_raw = convex_hull(upper_verts; merge_coplanar=true)
                s_raw = norm(rot_raw.v[rot_raw.f[1][1]] - rot_raw.v[rot_raw.f[1][2]])
                scaled_v = [v * (s / s_raw) for v in rot_raw.v]
                return convex_hull(scaled_v; merge_coplanar=true)
            end
        end
    end
    error("Could not construct pentagonal rotunda.")
end

const pentagonal_rotunda = rotunda

"""
    elongate(P::Polyhedron, face_idx::Integer; h::Union{Real, Nothing}=nothing)

Elongates the polyhedron `P` by extruding face `face_idx` into a prism.
- If `h` is `nothing`, the prism height defaults to the face edge length `s` to form square lateral faces.
"""
function elongate(P::Polyhedron, face_idx::Integer; h::Union{Real, Nothing}=nothing)
    1 <= face_idx <= length(P) || error("Face index $face_idx out of bounds (1:$(length(P))).")
    face_indices = P.f[face_idx]
    face_pts = [P.v[i] for i in face_indices]
    s = norm(face_pts[1] - face_pts[2])
    height = h !== nothing ? Float64(h) : s
    
    # Calculate outward unit normal
    poly_center = sum(P.v) / length(P.v)
    nv = face_normal(face_pts)
    c = centroid(face_pts)
    if (c - poly_center) ⋅ nv < 0
        nv = -nv
    end
    
    extruded_pts = [p + height * nv for p in face_pts]
    return convex_hull([P.v; extruded_pts]; merge_coplanar=true)
end

"""
    gyroelongate(P::Polyhedron, face_idx::Integer; h::Union{Real, Nothing}=nothing, gyration::Real=0.5)

Gyroelongates the polyhedron `P` by attaching an antiprism band to face `face_idx`.
- If `h` is `nothing`, the height is chosen to produce equilateral triangular faces.
"""
function gyroelongate(P::Polyhedron, face_idx::Integer; h::Union{Real, Nothing}=nothing, gyration::Real=0.5)
    1 <= face_idx <= length(P) || error("Face index $face_idx out of bounds (1:$(length(P))).")
    face_indices = P.f[face_idx]
    face_pts = [P.v[i] for i in face_indices]
    n = length(face_pts)
    s = norm(face_pts[1] - face_pts[2])
    
    poly_center = sum(P.v) / length(P.v)
    nv = face_normal(face_pts)
    c = centroid(face_pts)
    if (c - poly_center) ⋅ nv < 0
        nv = -nv
    end
    
    r = s / (2 * sin(π / n))
    d_xy_sq = 4 * r^2 * (sin(π * gyration / n))^2
    h_anti = if h !== nothing
        Float64(h)
    elseif s^2 > d_xy_sq
        sqrt(s^2 - d_xy_sq)
    else
        s * 0.8
    end
    
    # Rodrigues rotation by 2π * gyration / n around axis nv through centroid c
    θ = 2π * gyration / n
    K = @SMatrix [
         0.0    -nv[3]   nv[2];
         nv[3]   0.0    -nv[1];
        -nv[2]   nv[1]   0.0
    ]
    R = I + sin(θ)*K + (1 - cos(θ))*(K*K)
    
    extruded_pts = Pt3{Float64}[]
    for p in face_pts
        p_rot = c + R * (p - c)
        push!(extruded_pts, p_rot + h_anti * nv)
    end
    
    return convex_hull([P.v; extruded_pts]; merge_coplanar=true)
end

"""
    augment(P::Polyhedron, p_face_idx::Integer; cap::Polyhedron, cap_face_idx::Union{Integer, Nothing}=nothing, twist_index::Integer=0)

Augments polyhedron `P` by gluing `cap` onto face `p_face_idx`.
- `cap_face_idx`: The matching base face of `cap` (defaults to the largest polygon face of `cap`).
- `twist_index`: Rotational vertex offset to align vertices of matching faces.
"""
function augment(P::Polyhedron, p_face_idx::Integer; cap::Polyhedron, cap_face_idx::Union{Integer, Nothing}=nothing, twist_index::Integer=0)
    1 <= p_face_idx <= length(P) || error("Face index $p_face_idx out of bounds (1:$(length(P))).")
    p_face = [P.v[i] for i in P.f[p_face_idx]]
    n_vert = length(p_face)
    
    c_idx = if cap_face_idx !== nothing
        cap_face_idx
    else
        # Find matching face in cap with same polygon vertex count
        match = findfirst(f -> length(f) == n_vert, cap.f)
        match === nothing ? error("Could not find matching $n_vert-gon base in cap.") : match
    end
    
    cap_face = [cap.v[i] for i in cap.f[c_idx]]
    @assert length(cap_face) == n_vert "Face vertex count must match ($n_vert vs $(length(cap_face)))"
    
    c_p = centroid(p_face)
    n_p = face_normal(p_face)
    p_center = sum(P.v) / length(P.v)
    if (c_p - p_center) ⋅ n_p < 0
        n_p = -n_p
    end
    
    c_cap = centroid(cap_face)
    n_cap = face_normal(cap_face)
    cap_center = sum(cap.v) / length(cap.v)
    if (c_cap - cap_center) ⋅ n_cap < 0
        n_cap = -n_cap
    end
    
    # Scale cap so its base matches the destination face edge length
    s_p = norm(p_face[1] - p_face[2])
    s_cap = norm(cap_face[1] - cap_face[2])
    scale_factor = s_p / s_cap
    
    # Align cap normal (-n_cap) to destination normal (n_p)
    v_from = -n_cap
    v_to = n_p
    R_align = if isapprox(v_from, v_to; atol=1e-6)
        SMatrix{3,3,Float64}(I)
    elseif isapprox(v_from, -v_to; atol=1e-6)
        perp = abs(v_from[1]) < 0.9 ? Pt3{Float64}(1, 0, 0) : Pt3{Float64}(0, 1, 0)
        axis = (v_from × perp) / norm(v_from × perp)
        2 * (axis * transpose(axis)) - I
    else
        axis = (v_from × v_to) / norm(v_from × v_to)
        angle = acos(clamp(v_from ⋅ v_to, -1.0, 1.0))
        K = @SMatrix [
             0.0    -axis[3]   axis[2];
             axis[3]   0.0    -axis[1];
            -axis[2]   axis[1]   0.0
        ]
        I + sin(angle)*K + (1 - cos(angle))*(K*K)
    end
    
    # Find rotation around n_p that matches base vertices
    v0_cap_rot = R_align * ((cap_face[1] - c_cap) * scale_factor)
    v0_p = p_face[mod1(1 + twist_index, n_vert)] - c_p
    
    cos_θ = clamp((v0_cap_rot ⋅ v0_p) / (norm(v0_cap_rot) * norm(v0_p)), -1.0, 1.0)
    sin_θ = ((v0_cap_rot × v0_p) ⋅ n_p) / (norm(v0_cap_rot) * norm(v0_p))
    θ_match = atan(sin_θ, cos_θ)
    
    K_match = @SMatrix [
         0.0    -n_p[3]   n_p[2];
         n_p[3]   0.0    -n_p[1];
        -n_p[2]   n_p[1]   0.0
    ]
    R_match = I + sin(θ_match)*K_match + (1 - cos(θ_match))*(K_match*K_match)
    
    R_total = R_match * R_align
    
    transformed_cap_v = Pt3{Float64}[]
    for v in cap.v
        p_rel = (v - c_cap) * scale_factor
        p_trans = c_p + R_total * p_rel
        push!(transformed_cap_v, p_trans)
    end
    
    return convex_hull([P.v; transformed_cap_v]; merge_coplanar=true)
end

"""
    diminish(P::Polyhedron, cap_vertices::AbstractVector{<:Integer})

Diminishes polyhedron `P` by removing the specified cap vertices.
"""
function diminish(P::Polyhedron, cap_vertices::AbstractVector{<:Integer})
    remaining_indices = setdiff(1:length(P.v), cap_vertices)
    length(remaining_indices) >= 4 || error("Diminishing must leave at least 4 non-coplanar vertices.")
    return convex_hull(P.v[remaining_indices]; merge_coplanar=true)
end

"""
    gyrate(P::Polyhedron, cap_vertices::AbstractVector{<:Integer}; angle::Real, axis::Union{Pt3, Nothing}=nothing)

Gyrates (rotates) the specified cap vertices in `P` by `angle` around the symmetry axis.
"""
function gyrate(P::Polyhedron, cap_vertices::AbstractVector{<:Integer}; angle::Real, axis::Union{Pt3, Nothing}=nothing)
    cap_pts = [P.v[i] for i in cap_vertices]
    c_cap = centroid(cap_pts)
    
    rot_axis = if axis !== nothing
        axis / norm(axis)
    else
        poly_center = sum(P.v) / length(P.v)
        v = c_cap - poly_center
        norm(v) > 1e-6 ? v / norm(v) : Pt3{Float64}(0, 0, 1)
    end
    
    K = @SMatrix [
         0.0        -rot_axis[3]   rot_axis[2];
         rot_axis[3]   0.0        -rot_axis[1];
        -rot_axis[2]   rot_axis[1]   0.0
    ]
    R = I + sin(angle)*K + (1 - cos(angle))*(K*K)
    
    new_v = copy(P.v)
    for idx in cap_vertices
        p = P.v[idx]
        new_v[idx] = c_cap + R * (p - c_cap)
    end
    
    return convex_hull(new_v; merge_coplanar=true)
end
