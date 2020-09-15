module TinyInt
    # Overloaded functions
    import Base: getindex, length
    # Ensure library is compiled
    if Sys.iswindows()
        error("Windows is unsupported at this time.")
    end
    build_dir = string(dirname(@__FILE__), "/../deps/simdcomp")
    run(`make -s -C $build_dir`)
    libsimdcomp = build_dir * "/libsimdcomp.so"
    # Global C function tuple constants
    global const simdmaxmin = (:simdmaxmin, libsimdcomp)
    global const simdbits = (:bits, libsimdcomp)
    global const simdpackFOR = (:simdpackFOR, libsimdcomp)
    global const simdunpackFOR = (:simdunpackFOR, libsimdcomp)
    global const simdselectFOR = (:simdselectFOR, libsimdcomp)
    # Type definition and overloaded functions
    include("tinyintvec.jl")
    # Functions to pack and unpack arrays
    include("compress.jl")

    export TinyIntVec, pack, unpack, unpack!
end