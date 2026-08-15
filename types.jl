using StaticArrays

# Type aliases
const Pt2{T<:Real} = SVector{2, T} # Alias for 2D point/vector
const Pt3{T<:Real} = SVector{3, T} # Alias for 3D point/vector
const Points{N, T} = Vector{SVector{N, T}} # Alias for collection of points

"""
    Points(P...)

Constructs a Vector of SVectors from tuple/array point representations.
Promotes element types automatically.
"""
function Points(P::Union{Tuple, AbstractVector}...)
    N = length(P[1])
    svs = map(p -> SVector{N}(p...), P)
    T = promote_type(eltype.(svs)...)
    return SVector{N, T}[s for s in svs]
end

Points(pts::AbstractVector{<:AbstractVector}) = Points(pts...)
Points(pts::AbstractVector{<:Tuple}) = Points(pts...)

"""
    Polyhedron{T<:Real} <: AbstractVector{AbstractVector{Pt3{T}}}

A 3D polyhedral mesh storing vertices and face index offsets.
"""
struct Polyhedron{T<:Real} <: AbstractVector{AbstractVector{Pt3{T}}}
    v::Vector{Pt3{T}}
    i::Vector{Int}
    offsets::Vector{Int}
end

# Outer constructor from vertices vector and list of face index lists
function Polyhedron(v::AbstractVector{Pt3{T}}, f::AbstractVector{<:AbstractVector{<:Integer}}) where T
    indices = collect(Iterators.flatten(f))
    offsets = vcat(1, cumsum(length.(f)) .+ 1)
    return Polyhedron{T}(v, indices, offsets)
end

function Polyhedron(v::AbstractVector, f::AbstractVector{<:AbstractVector{<:Integer}})
    pts = Points(v...)
    return Polyhedron(pts, f)
end

"""
    Hedron{T<:Real} <: AbstractVector{Pt3{T}}

A zero-allocation view representing a single face of a `Polyhedron`.
"""
struct Hedron{T<:Real} <: AbstractVector{Pt3{T}}
    mesh::Polyhedron{T}
    face_idx::Int
end

Base.size(fv::Hedron) = (fv.mesh.offsets[fv.face_idx+1] - fv.mesh.offsets[fv.face_idx],)
Base.IndexStyle(::Type{<:Hedron}) = IndexLinear()

function Base.getindex(fv::Hedron, k::Int)
    @boundscheck checkbounds(fv, k)
    start_idx = fv.mesh.offsets[fv.face_idx]
    vertex_index = fv.mesh.i[start_idx + k - 1]
    return fv.mesh.v[vertex_index]
end

function Base.setindex!(fv::Hedron{T}, val::Pt3{T}, k::Int) where T
    @boundscheck checkbounds(fv, k)
    start_idx = fv.mesh.offsets[fv.face_idx]
    vertex_index = fv.mesh.i[start_idx + k - 1]
    fv.mesh.v[vertex_index] = val
end

# Polyhedron indexing returns Hedron (face view)
Base.size(P::Polyhedron) = (length(P.offsets) - 1,)
Base.IndexStyle(::Type{<:Polyhedron}) = IndexLinear()
Base.getindex(P::Polyhedron, k::Int) = Hedron(P, k)

"""
    FaceIndexList{T<:Real} <: AbstractVector{AbstractVector{Int}}

A view accessing face vertex indices via `P.f`.
"""
struct FaceIndexList{T<:Real} <: AbstractVector{AbstractVector{Int}}
    mesh::Polyhedron{T}
end

Base.size(fil::FaceIndexList) = size(fil.mesh)
Base.IndexStyle(::Type{<:FaceIndexList}) = IndexLinear()

function Base.getindex(fil::FaceIndexList, k::Int)
    @boundscheck checkbounds(fil, k)
    start_idx = fil.mesh.offsets[k]
    end_idx = fil.mesh.offsets[k+1] - 1
    return @view fil.mesh.i[start_idx:end_idx]
end

function Base.getproperty(P::Polyhedron, prop::Symbol)
    if prop === :f
        return FaceIndexList(P)
    end
    return getfield(P, prop)
end
