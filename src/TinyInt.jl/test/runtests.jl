#!/usr/bin/env julia

#Start Test Script
using TinyInt
using Base.Test

function test_pack(num_ints::Integer)
    # Tests packing
    println("Packing ", num_ints, " integers.")
    x = rand(1:10, num_ints)
    tinyx = pack(x)
    return true
end

function test_unpack(num_ints::Integer)
    # Tests unpacking
    println("Unpacking ", num_ints, " integers.")
    x = rand(1:10, num_ints)
    tinyx = pack(x)
    unpacked = unpack(tinyx)
    unpacked_ip = Vector{Int64}(num_ints)
    unpack!(tinyx, unpacked_ip)
    matchbool = unpacked == x && unpacked_ip == x
    if !matchbool
        return false
    end
    return true
end

function test_getindex(num_ints::Integer)
    # Tests getindex
    println("Accessing elements in ", num_ints, " packed integers.")
    x = rand(1:10, num_ints)
    tinyx = pack(x)
    for i = 1:num_ints
        if convert(Int64, tinyx[i]) !== x[i]
            return false
        end
    end
    return true
end

function run_tests()
    # Runs all tests for various integer sizing (less than a chunk, exactly a chunk, more than a chunk)
    for num_ints in [120, 128, 250]
        @test test_pack(num_ints)
        @test test_unpack(num_ints)
        @test test_getindex(num_ints)
    end
end

run_tests()