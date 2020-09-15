# Outputs a compressed integer array
function pack(x::Vector{T}) where {T<:Integer}
    # Length of x
    n = length(x)
    # Number of 128 integer chunks in compressed array
    nchunks = cld(n, 128)
    # Stores chunked compressed data
    data = Vector{Vector{m128i}}(undef, 0)
    # Bit width of compressed integer chunks
    b = Vector{UInt8}(undef, nchunks)
    # Offset of each chunk
    offset = Vector{UInt32}(undef, nchunks)
    # A temporary, guaranteed contiguous array to store chunks of x
    xtemp = Vector{UInt32}(undef, 128)
    xptr = pointer(xtemp)
    # Maximum bit width of chunk
    bmax = Vector{UInt32}(undef, 1)
    # Minimum bit width of chunk
    bmin = Vector{UInt32}(undef, 1)
    bmaxptr = pointer(bmax)
    bminptr = pointer(bmin)
    for chunk = 1:nchunks
        if chunk != nchunks
            ntrail = 0
        else
            # Pad the last chunk with zeros so it fits 128 integers
            ntrail = nchunks*128 - n
            fill!(xtemp, 0)
        end
        xstart = (chunk - 1)*128
        for i = 1:128 - ntrail
            @inbounds xtemp[i] = x[xstart + i]
        end
        # Evaluate and store offset
        offsetval = minimum(xtemp)
        offset[chunk] = offsetval
        # Evaluate and store bit width
        ccall(simdmaxmin, Nothing, (Ptr{UInt32}, Ptr{UInt32}, Ptr{UInt32}), xptr, bminptr, bmaxptr)
        bval = ccall(simdbits, UInt32, (UInt32,), bmax[1] - bmin[1])
        b[chunk] = bval
        # A compressed data chunk
        dataentry = Vector{m128i}(undef, bval)
        dataentryptr = pointer(dataentry)
        # Compress
        ccall(simdpackFOR, Nothing, (UInt32, Ptr{UInt32}, Ptr{m128i}, UInt32), offsetval, xptr, dataentryptr, bval)
        # Add compressed chunk to data
        push!(data, dataentry)
    end
    return TinyIntVec(data, b, n, offset)
end

# Outputs an uncompressed array
function unpack(tinyx::TinyIntVec)
    # Outputs an uncompressed array
    x = zeros(UInt32, length(tinyx.b)*128)
    nchunks = length(tinyx.b)
    for chunk = 1:nchunks
        xptr = pointer(x, (chunk-1)*128 + 1)
        dataentryptr = pointer(tinyx.data[chunk])
        ccall(simdunpackFOR, Nothing, (UInt32, Ptr{m128i}, Ptr{UInt32}, UInt32), tinyx.offset[chunk], dataentryptr, xptr, tinyx.b[chunk])
    end
    # Remove padding
    resize!(x, tinyx.n)
    return x
end

# Overwrite x with an uncompressed array
function unpack!(tinyx::TinyIntVec, x::Vector{T}) where {T<:Integer}
    # Guaranteed contiguous temporary array
    xtemp = Vector{UInt32}(undef, 128)
    xptr = pointer(xtemp)
    nchunks = length(tinyx.b)
    for chunk = 1:nchunks
        dataentryptr = pointer(tinyx.data[chunk])
        ccall(simdunpackFOR, Nothing, (UInt32, Ptr{m128i}, Ptr{UInt32}, UInt32), tinyx.offset[chunk], dataentryptr, xptr, tinyx.b[chunk])
        ntrail = ifelse(chunk != nchunks, 0, nchunks*128 - tinyx.n)
        xstart = (chunk - 1)*128
        for i = 1:128 - ntrail
            @inbounds x[xstart + i] = xtemp[i]
        end
    end
end

# Outputs an uncompressed chunk
function unpack(tinyx::TinyIntVec, chunk::Integer)
    # Outputs an uncompressed array
    x = Vector{UInt32}(undef, 128)
    xptr = pointer(x, (chunk-1)*128 + 1)
    dataentryptr = pointer(tinyx.data[chunk])
    ccall(simdunpackFOR, Nothing, (UInt32, Ptr{m128i}, Ptr{UInt32}, UInt32), tinyx.offset[chunk], dataentryptr, xptr, tinyx.b[chunk])
    return x
end

# Overwrite x with an uncompressed chunk
function unpack!(tinyx::TinyIntVec, x::Vector{UInt32}, chunk::Integer)
    ccall(simdunpackFOR, Nothing, (UInt32, Ptr{m128i}, Ptr{UInt32}, UInt32), tinyx.offset[chunk], pointer(tinyx.data[chunk]), pointer(x), tinyx.b[chunk])
end

# Finds the location within a chunk where the i'th element resides
i2chunk_i(i::Integer) = (i - 1) & 127

# Finds the chunk where the i'th element resides
i2chunk(i::Integer) = (i - 1) >> 7 + 1