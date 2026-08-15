# Prisms, Antiprisms, Pyramids, Bipyramids, and Trapezohedra (Gyrated Bipyramids)

"""
    prism(n::Integer; r::Real=1.0, h::Union{Real, Nothing}=nothing, regular::Bool=true)

Constructs a regular `n`-gonal prism (`n >= 3`).
- `r`: Radius of the circumscribed circle of the `n`-gonal bases.
- `h`: Height of the prism. If `nothing` and `regular=true`, `h` defaults to the base edge length
  `s = 2r * sin(π / n)` to produce a uniform prism with square lateral faces.
"""
function prism(n::Integer; r::Real=1.0, h::Union{Real, Nothing}=nothing, regular::Bool=true)
    n >= 3 || error("Prisms require n >= 3, got n = $n.")
    s = 2 * r * sin(π / n)
    height = h !== nothing ? Float64(h) : (regular ? s : 1.0)
    
    v = Pt3{Float64}[]
    # Bottom ring at z = -height / 2
    for k in 0:n-1
        θ = 2π * k / n
        push!(v, Pt3{Float64}(r * cos(θ), r * sin(θ), -height / 2))
    end
    # Top ring at z = +height / 2
    for k in 0:n-1
        θ = 2π * k / n
        push!(v, Pt3{Float64}(r * cos(θ), r * sin(θ), height / 2))
    end
    return convex_hull(v; merge_coplanar=true)
end

"""
    antiprism(n::Integer; r::Real=1.0, h::Union{Real, Nothing}=nothing, gyration::Real=0.5, regular::Bool=true)

Constructs an `n`-gonal antiprism (`n >= 3`).
- `r`: Radius of the circumscribed circle of the `n`-gonal bases.
- `h`: Height of the antiprism. If `nothing` and `regular=true`, `h` is chosen such that the lateral triangles
  are equilateral (uniform antiprism).
- `gyration`: Fraction of relative rotation between top and bottom bases in `[0, 1]`. Default is `0.5`
  (corresponding to a twist of `π / n`).
"""
function antiprism(n::Integer; r::Real=1.0, h::Union{Real, Nothing}=nothing, gyration::Real=0.5, regular::Bool=true)
    n >= 3 || error("Antiprisms require n >= 3, got n = $n.")
    s = 2 * r * sin(π / n)
    d_xy_sq = 4 * r^2 * (sin(π * gyration / n))^2
    
    height = if h !== nothing
        Float64(h)
    elseif regular && s^2 > d_xy_sq
        sqrt(s^2 - d_xy_sq)
    else
        s * 0.8
    end
    
    v = Pt3{Float64}[]
    # Bottom ring at z = -height / 2
    for k in 0:n-1
        θ = 2π * k / n
        push!(v, Pt3{Float64}(r * cos(θ), r * sin(θ), -height / 2))
    end
    # Top ring at z = +height / 2 rotated by 2π * gyration / n
    for k in 0:n-1
        θ = 2π * (k + gyration) / n
        push!(v, Pt3{Float64}(r * cos(θ), r * sin(θ), height / 2))
    end
    return convex_hull(v; merge_coplanar=true)
end

"""
    pyramid(n::Integer; r::Real=1.0, h::Union{Real, Nothing}=nothing, regular::Bool=true)

Constructs a regular `n`-gonal pyramid (`n >= 3`).
- `r`: Radius of the circumscribed circle of the `n`-gonal base.
- `h`: Height from base to apex. If `nothing` and `regular=true` (for `n ∈ {3, 4, 5}`), `h` is chosen
  such that lateral triangles are equilateral (e.g. regular tetrahedron for `n=3`, Johnson J1 for `n=4`,
  Johnson J2 for `n=5`).
"""
function pyramid(n::Integer; r::Real=1.0, h::Union{Real, Nothing}=nothing, regular::Bool=true)
    n >= 3 || error("Pyramids require n >= 3, got n = $n.")
    s = 2 * r * sin(π / n)
    
    height = if h !== nothing
        Float64(h)
    elseif regular && s > r
        sqrt(s^2 - r^2)
    else
        r * 1.0
    end
    
    v = Pt3{Float64}[]
    # Base ring at z = 0
    for k in 0:n-1
        θ = 2π * k / n
        push!(v, Pt3{Float64}(r * cos(θ), r * sin(θ), 0.0))
    end
    # Apex at z = height
    push!(v, Pt3{Float64}(0.0, 0.0, height))
    return convex_hull(v; merge_coplanar=true)
end

"""
    bipyramid(n::Integer; r::Real=1.0, h::Union{Real, Nothing}=nothing, regular::Bool=true)
    dipyramid(n::Integer; r::Real=1.0, h::Union{Real, Nothing}=nothing, regular::Bool=true)

Constructs a regular `n`-gonal bipyramid (dipyramid) (`n >= 3`).
- `r`: Radius of the equatorial `n`-gon.
- `h`: Total height from top apex to bottom apex. If `nothing` and `regular=true` (for `n ∈ {3, 4, 5}`),
  `h` is chosen such that all `2n` faces are equilateral triangles (e.g. Johnson J12 for `n=3`,
  regular octahedron for `n=4`, Johnson J13 for `n=5`).
"""
function bipyramid(n::Integer; r::Real=1.0, h::Union{Real, Nothing}=nothing, regular::Bool=true)
    n >= 3 || error("Bipyramids require n >= 3, got n = $n.")
    s = 2 * r * sin(π / n)
    
    half_h = if h !== nothing
        Float64(h) / 2
    elseif regular && s > r
        sqrt(s^2 - r^2)
    else
        r * 1.0
    end
    
    v = Pt3{Float64}[]
    # Equatorial ring at z = 0
    for k in 0:n-1
        θ = 2π * k / n
        push!(v, Pt3{Float64}(r * cos(θ), r * sin(θ), 0.0))
    end
    # Top and bottom apexes
    push!(v, Pt3{Float64}(0.0, 0.0, half_h))
    push!(v, Pt3{Float64}(0.0, 0.0, -half_h))
    return convex_hull(v; merge_coplanar=true)
end

const dipyramid = bipyramid

"""
    trapezohedron(n::Integer; r::Real=1.0, h::Union{Real, Nothing}=nothing, gyration::Real=0.5, regular::Bool=true)
    gyrobipyramid(n::Integer; r::Real=1.0, h::Union{Real, Nothing}=nothing, gyration::Real=0.5, regular::Bool=true)
    antidipyramid(n::Integer; r::Real=1.0, h::Union{Real, Nothing}=nothing, gyration::Real=0.5, regular::Bool=true)
    deltohedron(n::Integer; r::Real=1.0, h::Union{Real, Nothing}=nothing, gyration::Real=0.5, regular::Bool=true)

Constructs an `n`-gonal trapezohedron (gyrated bipyramid / antidipyramid / deltohedron) (`n >= 3`).
Its surface consists of `2n` quadrilateral faces (kites / deltoids).
- `gyration`: Controls the twist between upper and lower halves in `[0, 1]`.
  Default is `0.5`, yielding the canonical symmetric trapezohedron with congruent kite faces (e.g.
  rhombohedron for `n=3`, tetragonal trapezohedron for `n=4`, standard d10 die for `n=5`).
- `r`: Radius of the equatorial vertices.
- `h`: Height parameter of the primal antiprism.
"""
function trapezohedron(n::Integer; r::Real=1.0, h::Union{Real, Nothing}=nothing, gyration::Real=0.5, regular::Bool=true)
    n >= 3 || error("Trapezohedra require n >= 3, got n = $n.")
    ap = antiprism(n; r=r, h=h, gyration=gyration, regular=regular)
    return dual(ap)
end

const gyrobipyramid = trapezohedron
const antidipyramid = trapezohedron
const deltohedron = trapezohedron
