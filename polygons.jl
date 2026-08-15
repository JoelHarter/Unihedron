# 2D Polygon & Polygram Generators

using StaticArrays
using LinearAlgebra

# ============================================================================
# 1. Regular Polygons
# ============================================================================

"""
    regular_polygon(n::Integer; radius::Real=1.0, side::Union{Real, Nothing}=nothing, center=(0.0, 0.0), phase::Real=0.0) -> Vector{Pt2{Float64}}
    polygon(n::Integer; kwargs...)

Constructs a regular n-gon centered at `center`.
You can specify either the circumradius `radius` or the side length `side`.
`phase` allows rotating the initial vertex angle.
"""
function regular_polygon(n::Integer; radius::Real=1.0, side::Union{Real, Nothing}=nothing, center=(0.0, 0.0), phase::Real=0.0)
    n >= 3 || error("A polygon must have at least 3 vertices (got n=$n).")
    r = side !== nothing ? Float64(side) / (2.0 * sin(π / n)) : Float64(radius)
    cx, cy = Float64(center[1]), Float64(center[2])
    pts = Pt2{Float64}[]
    for k in 0:(n-1)
        θ = phase + 2.0 * π * k / n
        push!(pts, Pt2{Float64}(cx + r * cos(θ), cy + r * sin(θ)))
    end
    return pts
end

const polygon = regular_polygon

# Dedicated named regular polygon constructors:
equilateral_triangle(; side::Union{Real, Nothing}=nothing, radius::Real=1.0, kwargs...) = regular_polygon(3; radius=radius, side=side, kwargs...)
square_polygon(; side::Union{Real, Nothing}=nothing, radius::Real=1.0, kwargs...) = regular_polygon(4; radius=radius, side=side, phase=π/4, kwargs...)
regular_pentagon(; side::Union{Real, Nothing}=nothing, radius::Real=1.0, kwargs...) = regular_polygon(5; radius=radius, side=side, phase=π/10, kwargs...)
regular_hexagon(; side::Union{Real, Nothing}=nothing, radius::Real=1.0, kwargs...) = regular_polygon(6; radius=radius, side=side, kwargs...)
regular_heptagon(; side::Union{Real, Nothing}=nothing, radius::Real=1.0, kwargs...) = regular_polygon(7; radius=radius, side=side, kwargs...)
regular_octagon(; side::Union{Real, Nothing}=nothing, radius::Real=1.0, kwargs...) = regular_polygon(8; radius=radius, side=side, phase=π/8, kwargs...)
regular_nonagon(; side::Union{Real, Nothing}=nothing, radius::Real=1.0, kwargs...) = regular_polygon(9; radius=radius, side=side, kwargs...)
regular_decagon(; side::Union{Real, Nothing}=nothing, radius::Real=1.0, kwargs...) = regular_polygon(10; radius=radius, side=side, kwargs...)
regular_hendecagon(; side::Union{Real, Nothing}=nothing, radius::Real=1.0, kwargs...) = regular_polygon(11; radius=radius, side=side, kwargs...)
regular_dodecagon(; side::Union{Real, Nothing}=nothing, radius::Real=1.0, kwargs...) = regular_polygon(12; radius=radius, side=side, kwargs...)

# ============================================================================
# 2. Polygrams & Star Polygons
# ============================================================================

"""
    polygram(p::Integer, q::Integer=2; radius::Real=1.0, center=(0.0, 0.0), phase::Real=0.0)

Generates the regular star polygon or compound polygram {p/q} in Schläfli notation.
- If `gcd(p, q) == 1`, returns a single `Vector{Pt2{Float64}}` traversing all `p` vertices.
- If `gcd(p, q) > 1`, returns a `Vector{Vector{Pt2{Float64}}}` containing the multiple regular components
  (e.g., the hexagram {6/2} returns two triangles).
"""
function polygram(p::Integer, q::Integer=2; radius::Real=1.0, center=(0.0, 0.0), phase::Real=0.0)
    p >= 3 || error("p must be >= 3")
    1 <= q < p || error("q must satisfy 1 <= q < p (got q=$q, p=$p)")
    r = Float64(radius)
    cx, cy = Float64(center[1]), Float64(center[2])
    g = gcd(p, q)
    
    if g == 1
        pts = Pt2{Float64}[]
        curr = 0
        for _ in 0:(p-1)
            θ = phase + 2.0 * π * curr / p
            push!(pts, Pt2{Float64}(cx + r * cos(θ), cy + r * sin(θ)))
            curr = (curr + q) % p
        end
        return pts
    else
        components = Vector{Pt2{Float64}}[]
        m = div(p, g)
        for comp in 0:(g-1)
            comp_pts = Pt2{Float64}[]
            for k in 0:(m-1)
                idx = (comp + k * q) % p
                θ = phase + 2.0 * π * idx / p
                push!(comp_pts, Pt2{Float64}(cx + r * cos(θ), cy + r * sin(θ)))
            end
            push!(components, comp_pts)
        end
        return components
    end
end

"""
    star_polygon(n::Integer; r_outer::Real=1.0, r_inner::Union{Real, Nothing}=nothing, center=(0.0, 0.0), phase::Real=0.0) -> Vector{Pt2{Float64}}
    star(n::Integer; kwargs...)

Constructs a non-self-intersecting 2n-gon star outline with alternating outer and inner vertices.
If `r_inner` is omitted, it defaults to the exact canonical chord-intersection radius for an n-pointed regular star.
"""
function star_polygon(n::Integer; r_outer::Real=1.0, r_inner::Union{Real, Nothing}=nothing, center=(0.0, 0.0), phase::Real=0.0)
    n >= 3 || error("Star must have at least 3 points (got n=$n).")
    r_out = Float64(r_outer)
    # Default inner radius: chord intersection of {n/2}
    r_in = r_inner !== nothing ? Float64(r_inner) : r_out * (cos(π / n) / (cos(π / n) + sin(π / n) * tan(π / (2*n))))
    cx, cy = Float64(center[1]), Float64(center[2])
    
    pts = Pt2{Float64}[]
    for k in 0:(2*n - 1)
        r = (k % 2 == 0) ? r_out : r_in
        θ = phase + π * k / n
        push!(pts, Pt2{Float64}(cx + r * cos(θ), cy + r * sin(θ)))
    end
    return pts
end

const star = star_polygon

# Dedicated star constructors:
pentagram(; radius::Real=1.0, kwargs...) = polygram(5, 2; radius=radius, phase=π/10, kwargs...)
hexagram(; radius::Real=1.0, kwargs...) = polygram(6, 2; radius=radius, kwargs...)
heptagram(q::Integer=2; radius::Real=1.0, kwargs...) = polygram(7, q; radius=radius, kwargs...)
octagram(q::Integer=3; radius::Real=1.0, kwargs...) = polygram(8, q; radius=radius, kwargs...)
decagram(q::Integer=3; radius::Real=1.0, kwargs...) = polygram(10, q; radius=radius, kwargs...)

# ============================================================================
# 3. Parametric & Classical 2D Polygons
# ============================================================================

"""
    rectangle(width::Real, height::Real; center=(0.0, 0.0)) -> Vector{Pt2{Float64}}

Constructs a rectangle of the given `width` and `height`.
"""
function rectangle(width::Real, height::Real; center=(0.0, 0.0))
    w2 = Float64(width) / 2.0
    h2 = Float64(height) / 2.0
    cx, cy = Float64(center[1]), Float64(center[2])
    return Pt2{Float64}[
        Pt2{Float64}(cx - w2, cy - h2),
        Pt2{Float64}(cx + w2, cy - h2),
        Pt2{Float64}(cx + w2, cy + h2),
        Pt2{Float64}(cx - w2, cy + h2)
    ]
end

"""
    rhombus(d1::Real, d2::Real; center=(0.0, 0.0)) -> Vector{Pt2{Float64}}

Constructs a rhombus with diagonals of length `d1` (along x) and `d2` (along y).
"""
function rhombus(d1::Real, d2::Real; center=(0.0, 0.0))
    x2 = Float64(d1) / 2.0
    y2 = Float64(d2) / 2.0
    cx, cy = Float64(center[1]), Float64(center[2])
    return Pt2{Float64}[
        Pt2{Float64}(cx + x2, cy),
        Pt2{Float64}(cx, cy + y2),
        Pt2{Float64}(cx - x2, cy),
        Pt2{Float64}(cx, cy - y2)
    ]
end

"""
    trapezoid(top_w::Real, bot_w::Real, height::Real; center=(0.0, 0.0)) -> Vector{Pt2{Float64}}

Constructs an isosceles trapezoid with parallel sides `top_w` and `bot_w` and altitude `height`.
"""
function trapezoid(top_w::Real, bot_w::Real, height::Real; center=(0.0, 0.0))
    tw2 = Float64(top_w) / 2.0
    bw2 = Float64(bot_w) / 2.0
    h2 = Float64(height) / 2.0
    cx, cy = Float64(center[1]), Float64(center[2])
    return Pt2{Float64}[
        Pt2{Float64}(cx - bw2, cy - h2),
        Pt2{Float64}(cx + bw2, cy - h2),
        Pt2{Float64}(cx + tw2, cy + h2),
        Pt2{Float64}(cx - tw2, cy + h2)
    ]
end

"""
    parallelogram(base::Real, side::Real, angle::Real; center=(0.0, 0.0)) -> Vector{Pt2{Float64}}

Constructs a parallelogram with base length `base`, side length `side`, and interior `angle` (in radians).
"""
function parallelogram(base::Real, side::Real, angle::Real; center=(0.0, 0.0))
    b = Float64(base)
    s = Float64(side)
    θ = Float64(angle)
    dx = s * cos(θ)
    dy = s * sin(θ)
    # Center offset
    cx, cy = Float64(center[1]) - (b + dx) / 2.0, Float64(center[2]) - dy / 2.0
    return Pt2{Float64}[
        Pt2{Float64}(cx, cy),
        Pt2{Float64}(cx + b, cy),
        Pt2{Float64}(cx + b + dx, cy + dy),
        Pt2{Float64}(cx + dx, cy + dy)
    ]
end

"""
    kite_polygon(d1::Real, d2::Real; split::Real=0.35, center=(0.0, 0.0)) -> Vector{Pt2{Float64}}

Constructs a symmetric kite with orthogonal diagonals `d1` (width) and `d2` (height).
"""
function kite_polygon(d1::Real, d2::Real; split::Real=0.35, center=(0.0, 0.0))
    w2 = Float64(d1) / 2.0
    h = Float64(d2)
    y_top = h * (1.0 - Float64(split))
    y_bot = -h * Float64(split)
    cx, cy = Float64(center[1]), Float64(center[2])
    return Pt2{Float64}[
        Pt2{Float64}(cx, cy + y_top),
        Pt2{Float64}(cx + w2, cy),
        Pt2{Float64}(cx, cy + y_bot),
        Pt2{Float64}(cx - w2, cy)
    ]
end

"""
    ellipse_polygon(a::Real, b::Real; n::Integer=32, center=(0.0, 0.0), phase::Real=0.0) -> Vector{Pt2{Float64}}

Approximates an ellipse with semi-axes `a` and `b` as an n-gon.
"""
function ellipse_polygon(a::Real, b::Real; n::Integer=32, center=(0.0, 0.0), phase::Real=0.0)
    n >= 3 || error("n must be >= 3")
    cx, cy = Float64(center[1]), Float64(center[2])
    pts = Pt2{Float64}[]
    for k in 0:(n-1)
        θ = phase + 2.0 * π * k / n
        push!(pts, Pt2{Float64}(cx + Float64(a) * cos(θ), cy + Float64(b) * sin(θ)))
    end
    return pts
end

"""
    reuleaux_polygon(n::Integer=3; radius::Real=1.0, num_samples::Integer=24, center=(0.0, 0.0)) -> Vector{Pt2{Float64}}

Constructs a constant-width Reuleaux polygon with an odd number of sides `n` (default 3: Reuleaux triangle).
"""
function reuleaux_polygon(n::Integer=3; radius::Real=1.0, num_samples::Integer=24, center=(0.0, 0.0))
    isodd(n) && n >= 3 || error("Reuleaux polygon must have an odd number of vertices >= 3 (got n=$n).")
    r = Float64(radius)
    cx, cy = Float64(center[1]), Float64(center[2])
    
    # Vertices of the regular n-gon base
    base_verts = [Pt2{Float64}(r * cos(2π * k / n), r * sin(2π * k / n)) for k in 0:(n-1)]
    width = norm(base_verts[1] - base_verts[div(n+1, 2)])
    
    pts = Pt2{Float64}[]
    for i in 1:n
        opp_idx = mod1(i + div(n, 2), n)
        opp_center = base_verts[opp_idx]
        
        # Arc connecting vertex i to vertex i+1 centered at opp_center
        start_angle = atan(base_verts[i][2] - opp_center[2], base_verts[i][1] - opp_center[1])
        next_i = (i == n) ? 1 : i + 1
        end_angle = atan(base_verts[next_i][2] - opp_center[2], base_verts[next_i][1] - opp_center[1])
        
        # Ensure positive CCW sweep
        if end_angle < start_angle
            end_angle += 2π
        end
        
        step_samples = max(2, div(num_samples, n))
        for s in 0:(step_samples - 1)
            t = s / step_samples
            ang = start_angle + t * (end_angle - start_angle)
            push!(pts, Pt2{Float64}(cx + opp_center[1] + width * cos(ang), cy + opp_center[2] + width * sin(ang)))
        end
    end
    return pts
end
