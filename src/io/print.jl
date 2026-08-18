# Unihedron Image Rendering & Printing Engine
# Generates high-resolution raster (PNG, JPG) and vector (SVG, PDF) image printouts.

using GLMakie
using GLMakie.GeometryBasics
using StaticArrays
using LinearAlgebra

"""
    _make_image_transparent!(filepath::AbstractString; bg_color=RGB{Float32}(1,1,1), tol=0.02)

Converts the pure background color of a saved raster image file to transparent RGBA.
Uses border flood-filling to preserve interior white details.
"""
function _make_image_transparent!(filepath::AbstractString; bg_color=RGB{Float32}(1,1,1), tol=0.02)
    img = GLMakie.FileIO.load(filepath)
    H, W = size(img)
    rgba = Matrix{RGBA{Float32}}(undef, H, W)
    for y in 1:H, x in 1:W
        c = RGB{Float32}(img[y, x])
        rgba[y, x] = RGBA{Float32}(c.r, c.g, c.b, 1.0f0)
    end
    
    visited = falses(H, W)
    queue = Tuple{Int, Int}[]
    
    for x in 1:W
        for y in [1, H]
            c = RGB{Float32}(img[y, x])
            if norm([c.r - bg_color.r, c.g - bg_color.g, c.b - bg_color.b]) < tol
                visited[y, x] = true
                push!(queue, (y, x))
            end
        end
    end
    for y in 1:H
        for x in [1, W]
            if !visited[y, x]
                c = RGB{Float32}(img[y, x])
                if norm([c.r - bg_color.r, c.g - bg_color.g, c.b - bg_color.b]) < tol
                    visited[y, x] = true
                    push!(queue, (y, x))
                end
            end
        end
    end
    
    while !isempty(queue)
        cy, cx = popfirst!(queue)
        rgba[cy, cx] = RGBA{Float32}(bg_color.r, bg_color.g, bg_color.b, 0.0f0)
        
        for (dy, dx) in [(-1, 0), (1, 0), (0, -1), (0, 1)]
            ny, nx = cy + dy, cx + dx
            if 1 <= ny <= H && 1 <= nx <= W && !visited[ny, nx]
                c = RGB{Float32}(img[ny, nx])
                dist = norm([c.r - bg_color.r, c.g - bg_color.g, c.b - bg_color.b])
                if dist < tol
                    visited[ny, nx] = true
                    push!(queue, (ny, nx))
                end
            end
        end
    end
    
    GLMakie.FileIO.save(filepath, rgba)
    return filepath
end

"""
    print_polyhedron(P::Polyhedron, filepath::AbstractString; 
                     size=(800, 800), 
                     px_per_unit=2.0, 
                     color=:auto, 
                     edgecolor=:black, 
                     linewidth=2.0, 
                     show_faces=true, 
                     show_edges=true, 
                     show_vertices=false, 
                     vertex_color=:crimson, 
                     vertex_size=8, 
                     color_by_face_size=false, 
                     colormap=:viridis, 
                     title=nothing, 
                     transparent=false,
                     kwargs...)

Renders a `Polyhedron` in 3D using Makie and writes a high-resolution image to `filepath` (.png, .jpg, .svg, .pdf).
If `transparent=true`, saves PNG images with a fully transparent background.
"""
function print_polyhedron(P::Polyhedron, filepath::AbstractString; 
                          size::Tuple{Int, Int}=(800, 800), 
                          px_per_unit::Real=2.0, 
                          color=:auto, 
                          edgecolor=:black, 
                          linewidth=2.0, 
                          show_faces::Bool=true, 
                          show_edges::Bool=true, 
                          show_vertices::Bool=false, 
                          vertex_color=:crimson, 
                          vertex_size::Real=8, 
                          color_by_face_size::Bool=false, 
                          colormap=:viridis, 
                          title::Union{AbstractString, Nothing}=nothing, 
                          transparent::Bool=false,
                          kwargs...)
    fig = display_polyhedron(P; 
                             size=size, 
                             color=color, 
                             edgecolor=edgecolor, 
                             linewidth=linewidth, 
                             show_faces=show_faces, 
                             show_edges=show_edges, 
                             show_vertices=show_vertices, 
                             vertex_color=vertex_color, 
                             vertex_size=vertex_size, 
                             color_by_face_size=color_by_face_size, 
                             colormap=colormap, 
                             title=title, 
                             kwargs...)
    GLMakie.save(filepath, fig; px_per_unit=Float32(px_per_unit))
    if transparent && endswith(lowercase(filepath), ".png")
        _make_image_transparent!(filepath)
    end
    return filepath
end

const save_polyhedron_image = print_polyhedron

"""
    print_polygon(poly::AbstractVector{<:Union{Pt2, Pt3}}, filepath::AbstractString; 
                  size=(600, 600), 
                  px_per_unit=2.0, 
                  color=:dodgerblue, 
                  edgecolor=:black, 
                  linewidth=2.0, 
                  title="Polygon", 
                  kwargs...)

Renders a 2D or 3D polygon and writes an image file to `filepath`.
"""
function print_polygon(poly::AbstractVector{<:Pt2}, filepath::AbstractString; 
                       size::Tuple{Int, Int}=(600, 600), 
                       px_per_unit::Real=2.0, 
                       color=:dodgerblue, 
                       edgecolor=:black, 
                       linewidth=2.0, 
                       title::AbstractString="2D Polygon", 
                       kwargs...)
    fig = display_polygon(poly; size=size, color=color, edgecolor=edgecolor, linewidth=linewidth, title=title, kwargs...)
    GLMakie.save(filepath, fig; px_per_unit=Float32(px_per_unit))
    return filepath
end

function print_polygon(poly::AbstractVector{<:Pt3}, filepath::AbstractString; 
                       size::Tuple{Int, Int}=(700, 700), 
                       px_per_unit::Real=2.0, 
                       color=:dodgerblue, 
                       edgecolor=:black, 
                       linewidth=2.0, 
                       title::AbstractString="3D Polygon", 
                       kwargs...)
    fig = display_polygon(poly; size=size, color=color, edgecolor=edgecolor, linewidth=linewidth, title=title, kwargs...)
    GLMakie.save(filepath, fig; px_per_unit=Float32(px_per_unit))
    return filepath
end

const save_polygon_image = print_polygon

"""
    print_image(poly_or_polyhedron, filepath::AbstractString; kwargs...)
    print_image(name::Symbol, filepath::AbstractString; kwargs...)
    save_image(...)

Unified image printing dispatcher for polyhedra, 2D polygons, 3D polygons, and named solids.
"""
print_image(P::Polyhedron, filepath::AbstractString; kwargs...) = print_polyhedron(P, filepath; kwargs...)
print_image(poly::AbstractVector{<:Union{Pt2, Pt3}}, filepath::AbstractString; kwargs...) = print_polygon(poly, filepath; kwargs...)

function print_image(name::Symbol, filepath::AbstractString; kwargs...)
    P = if haskey(PLATONIC_SOLID_MAP, name)
        platonic(name)
    elseif haskey(ARCHIMEDEAN_SOLID_MAP, name)
        archimedean(name)
    elseif haskey(KEPLER_POINSOT_SOLID_MAP, name)
        kepler_poinsot(name)
    elseif haskey(CATALAN_SOLID_MAP, name)
        catalan(name)
    elseif haskey(COOKSON_SOLID_MAP, name)
        cookson(name)
    elseif haskey(JOHNSON_SOLID_MAP, name)
        johnson(name)
    else
        error("Unknown solid symbol: :$name")
    end
    title_str = titlecase(replace(string(name), "_" => " "))
    return print_polyhedron(P, filepath; title=title_str, kwargs...)
end

const save_image = print_image

"""
    print_gallery(solids::AbstractVector{<:Polyhedron}, filepath::AbstractString; 
                  titles=nothing, 
                  cols::Int=4, 
                  size=nothing, 
                  px_per_unit=2.0, 
                  color=:auto,
                  color_by_face_size=false, 
                  backgroundcolor=:white,
                  show_axis::Bool=false,
                  kwargs...)

Generates and saves a multi-solid grid gallery image on a clean, plain background with no axes or markers.
"""
function print_gallery(solids::AbstractVector{<:Polyhedron}, filepath::AbstractString; 
                       titles::Union{AbstractVector{<:AbstractString}, Nothing}=nothing, 
                       cols::Int=4, 
                       size::Union{Tuple{Int, Int}, Nothing}=nothing, 
                       px_per_unit::Real=2.0, 
                       color=:auto,
                       color_by_face_size::Bool=false, 
                       backgroundcolor=:white,
                       show_axis::Bool=false,
                       kwargs...)
    N = length(solids)
    rows = cld(N, cols)
    fig_size = size !== nothing ? size : (cols * 350, rows * 350)
    fig = Figure(size=fig_size, backgroundcolor=backgroundcolor)
    
    for (idx, P) in enumerate(solids)
        r = div(idx - 1, cols) + 1
        c = mod(idx - 1, cols) + 1
        hdr = (titles !== nothing && idx <= length(titles)) ? titles[idx] : "Solid $idx"
        ax = Axis3(fig[r, c], aspect=:data, title=hdr)
        if !show_axis
            hidedecorations!(ax)
            hidespines!(ax)
        end
        display_polyhedron!(ax, P; color=color, color_by_face_size=color_by_face_size, show_vertices=false, kwargs...)
    end
    
    GLMakie.save(filepath, fig; px_per_unit=Float32(px_per_unit))
    return filepath
end
