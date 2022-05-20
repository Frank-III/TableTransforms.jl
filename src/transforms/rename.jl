# ------------------------------------------------------------------
# Licensed under the MIT License. See LICENSE in the project root.
# ------------------------------------------------------------------

"""
    Rename(:col₁ => :newcol₁, :col₂ => :newcol₂, ..., :col₁ => :newcolₙ)

The transform that renames `col₁` to `newcol₁`, `col₂` to `newcol₂`, ...

# Examples

```julia
Rename(:a => :x, :c => :y)
Rename("a" => "x", "c" => "y")
```
"""
struct Rename <: Stateless
  names::Dict{Symbol,Symbol}
end

Rename(names::Dict) = _symboldict(names) |> Rename
Rename(names::Pair) = _pairsyms(names) |> Dict |> Rename
Rename(names...) = _pairsyms.(names) |> Dict |> Rename

_symboldict(names) = Dict(Symbol(k)=>Symbol(v) for (k, v) in pairs(names))

_pairsyms(x::Pair) = Symbol(first(x)) => Symbol(last(x))

function apply(transform::Rename, table)
  _rename(transform.names, table)
end

function revert(transform::Rename, table, cache)
  # reversing the key-value pairs of the Dict
  newnames = Dict(new => old for (old, new) in transform.names)
  _rename(newnames, table) |> first
end


function _rename(names, table)
  cols = Tables.columns(table)
  oldnames = Tables.columnnames(cols)

  # check if requested renames exist in the table
  @assert keys(names) ⊆ oldnames "invalid column names"

  # use new names if necessary
  newnames = map(oldnames) do oldname
    oldname in keys(names) ? names[oldname] : oldname
  end

  # table with new tables
  vals = [Tables.getcolumn(cols, name) for name in oldnames]
  𝒯 = (; zip(newnames, vals)...) |> Tables.materializer(table)
  
  𝒯, nothing
end