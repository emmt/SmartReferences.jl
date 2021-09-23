# Smart references for Julia

[SmartReferences](https://github.com/emmt/SmartReferences.jl) is a small
[Julia](http://julialang.org/) package providing simple objects that can get or
set the value of a specific entry, property, or field of another object.  This
is useful to *pass by reference* this entry (property, or field) to some
function as a single argument.

The most simple example is:

```.jl
B = SmartRef(A, i)
```

which yields an object `B` that is a reference to the `i`-th entry of `A` or,
if `i` is a symbol (and `A` is not a dictionary with symbolic keys) to the
property (or field) `i` of `A`.  Then `B` can be used as follows:

```.jl
B[]
```

to retrieve the value of the referenced entry (property, or field) of `A`;
and as:

```.jl
B[] = x
```

to set the value of the referenced entry (property, or field) of `A`.

Depending on the types of its arguments, `SmartRef` may yield different
concrete types of object. If a specific kind of reference is needed, call one
of:

- `B = IndexRef(A,i)` to map the `B[]` and `B[] = x` syntaxes to
  `getindex(A,i)` and `setindex!(A,x,i)` respectively.

- `B = PropertyRef(A,i)`, with `i` a `Symbol`, to map the `B[]` and `B[] = x`
  syntaxes to `getproperty(A,i)` and `setproperty!(A,i,x)` respectively.

- `B = FieldRef(A,i)`, with `i` a `Symbol`, to map the `B[]` and `B[] = x`
  syntaxes to `getfield(A,i)` and `setfield!(A,i,convert(T,x))` respectively and
  with `T = fieldtype(typeof(A),i)`.
