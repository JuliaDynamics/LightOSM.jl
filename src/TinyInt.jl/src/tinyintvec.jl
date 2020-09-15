const m128i = VecElement{Int128}
struct TinyIntVec
    data::Vector{Vector{m128i}}
    b::Vector{UInt8}
    n::Int64
    offset::Vector{UInt32}
end

# Overloaded function for getindex
function getindex(tinyx::TinyIntVec, i::Integer)
    @boundscheck (i <= tinyx.n && i > 0) || throw(BoundsError(i))
    chunk = i2chunk(i)
    ccall(simdselectFOR, UInt32, (UInt32, Ptr{m128i}, UInt32, Int32), tinyx.offset[chunk], pointer(tinyx.data[chunk]), tinyx.b[chunk], i2chunk_i(i))
end

# Overloaded function for length
length(tinyx::TinyIntVec) = tinyx.n