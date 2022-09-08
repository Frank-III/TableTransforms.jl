struct SelectRename{S <: ColSpec}
    select::S
    oname::S
    nname::Vector{Symbol}
end

function transform_args(args)
    select = filter(x -> x isa Col, args)
    rename = filter(x -> x isa Pair, args)
    oname = collect(getfield.(rename, :first))
    select = select ∪ oname
    nname = Symbol.(collect(getfield.(rename, :second)))
    select, oname, nname
end

function SelectRename(args...)
    SelectRename(transform_args(args)...)
end

isrevertible(transform::SelectRename) = true

function apply(transform::SelectRename, table)

    re = Dict(o .=> transform.nname)
    #rewrite rename function
    ts = Select(se) → Rename(re)
    # result cache, ts
    apply(ts, table), ts
end

function revert(::SelectRename, newtable, cache)
    c, ts = cache
    revert(ts, newtable, c)
end
