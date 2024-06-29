module FixedFunctions

export FixedFunction, Free, VarFree

"""
    Free()

A singleton type used to indicate a single free argument in a [`FixedFunction`](@ref).
"""
struct Free end

"""
    VarFree()

A singleton type used to indicate a variable-length sequence of free arguments in a
[`FixedFunction`](@ref).
"""
struct VarFree end

"""
    FixedFunction{F,A,B} <: Function
    FixedFunction(func, args, [kwargs])

A type representing the partial application of a function `func::F` to a tuple of positional
arguments `args::A` and a named tuple of keyword arguments `kwargs::B`.

This binds (or "fixes") some of the arguments to a function while leaving the remaining
arguments unbound (or "free"), to be assigned when later called. A single free positional
argument is indicated by [`Free()`](@ref) and a variable-length sequence of free arguments
is indicated by [`VarFree()`](@ref).
"""
struct FixedFunction{F,A,B}
    func::F
    args::A
    kwargs::B

    function FixedFunction(func, args::Tuple, kwargs::NamedTuple)
        nfree = count(==(Free()), args)
        nvarfree = count(==(VarFree()), args)

        if nfree + nvarfree == 0
            msg = "cannot create a FixedFunction without any free arguments"
            throw(ArgumentError(msg))
        end

        if nvarfree > 1
            msg = "cannot create a FixedFunction with more than one variable-length sequence of free arguments"
            throw(ArgumentError(msg))
        end

        return new{typeof(func),typeof(args),typeof(kwargs)}(func, args, kwargs)
    end
end

FixedFunction(func, args) = FixedFunction(func, args, (;))

"""
    (fixed::FixedFunction)(args...; kwargs...)

Apply a partially-applied function `fixed` to positional arguments `args` and keyword
arguments `kwargs`.
"""
@generated function (fixed::FixedFunction{F,A,B})(args...; kwargs...) where {F,A,B}
    nargs = length(args)
    nfree = count(==(Free), A.parameters)
    nvarfree = count(==(VarFree), A.parameters)

    if nvarfree == 0 && nargs != nfree
        msg = "expected exactly $nfree arguments, but received $nargs instead"
        throw(ArgumentError(msg))
    end

    if nvarfree == 1 && nargs < nfree
        msg = "expected at least $nfree arguments, but received $nargs instead"
        throw(ArgumentError(msg))
    end

    i, expr = 0, :(fixed.func(; fixed.kwargs..., kwargs...))
    for (j, T) in enumerate(A.parameters)
        if T == Free
            push!(expr.args, :(args[$(i += 1)]))
            continue
        end

        if T == VarFree
            for _ in 1:(nargs - nfree)
                push!(expr.args, :(args[$(i += 1)]))
            end

            continue
        end

        push!(expr.args, :(fixed.args[$j]))
    end

    return expr
end

end
