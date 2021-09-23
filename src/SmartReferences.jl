module SmartReferences

export SmartRef, IndexRef, FieldRef, PropertyRef

import Base: getindex, setindex!
using Base: @propagate_inbounds

"""

    SmartRef(A, i) -> B

yields an object `B` that is a reference to the `i`-th entry of `A` or, if `i`
is a symbol (and `A` is not a dictionary with symbolic keys) to the property
(or the field) `i` of `A`.  This provides an economical mean to pass a specific
array entry or object property or field by *reference* to another function.
The returned object can be used as follows:

    B[]     # to retrieve the value of the referenced entry/property/field
    B[] = x # to set the value of the referenced entry/property/field

Call [`IndexRef`](@ref), [`PropertyRef`](@ref), or [`FieldRef`](@ref) directly
if a specific kind of reference is needed.

!!! warning
    Do not confuse smart references and `Ref`, the former are immutable while
    the latter is mutable and thus offers some guarantees about the lifetime of
    the referenced object.

""" SmartRef

abstract type SmartRef end

SmartRef(A, i) = IndexRef(A, i)
SmartRef(A, sym::Symbol) = PropertyRef(A,sym)
SmartRef(A::AbstractDict{Symbol}, key::Symbol) = IndexRef(A, key)

"""
    IndexRef(A, i) -> B

yields an object `B` that is a reference to the `i`-th entry of `A`.  This
provides an economical mean to pass a specific array entry by *reference* to
another function.  The returned object can be used as follows:

    B[]      # same as getindex(A,i), that is A[i]
    B[] = x  # same as setindex!(A,x,i), that is A[i] = x

There is no restrictions to the types of `A` and `i` as long as the syntaxes
`A[i]` and `A[i] = x` make sense.

""" IndexRef

struct IndexRef{T,I} <: SmartRef
    parent::T
    index::I
end

@inline @propagate_inbounds getindex(A::IndexRef) =
    getindex(A.parent, A.index)

@inline @propagate_inbounds setindex!(A::IndexRef, x) =
   setindex!(A.parent, x, A.index)

"""
    PropertyRef(A, sym) -> B

yields an object `B` that is a reference to the property (or field) `sym` of
`A`.  This provides an economical mean to pass a specific property (or field)
of an object by *reference* to another function.  The returned object can be
used as follows:

    B[]      # same as getproperty(A,sym)
    B[] = x  # same as setproperty!(A,sym,x)

There is no restrictions to the type of `A` as long as the calls
`getproperty(A,sym)` and `setproperty!(A,sym,x)` make sense.

""" PropertyRef

struct PropertyRef{S,T} <: SmartRef
    parent::T
end

PropertyRef(A::T, sym::Symbol) where {T} = PropertyRef{sym,T}(A)

@inline getindex(A::PropertyRef{S}) where {S} =
    getproperty(A.parent, S)

@inline setindex!(A::PropertyRef{S}, x) where {S} =
    setproperty!(A.parent, S, x)

"""
    FieldRef(A, sym) -> B

yields an object `B` that is a reference to the field `sym` of `A`.  This
provides an economical mean to pass a specific field of an object by
*reference* to another function.  The returned object can be used as follows:

    B[]      # same as getfield(A,sym)
    B[] = x  # same as setfield!(A,sym,convert(fieldtype(typeof(A),sym),x))

There is no restrictions to the type of `A` as long as the syntaxes
`getfield(A,sym)` and `setfield!(A,sym,...)` make sense.  The latter implying
that `A` is mutable.

""" FieldRef

struct FieldRef{S,T} <: SmartRef
    parent::T
end

FieldRef(A::T, sym::Symbol) where {T} = FieldRef{sym,T}(A)

@inline getindex(A::FieldRef{S}) where {S} =
    getfield(A.parent, S)

@inline setindex!(A::FieldRef{S,T}, x) where {S,T} =
    setfield!(A.parent, S, convert(fieldtype(T, S), x))

end # module
