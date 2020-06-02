using Documenter, MicroCollections

makedocs(;
    modules = [MicroCollections],
    format = Documenter.HTML(),
    pages = ["Home" => "index.md", hide("internals.md")],
    repo = "https://github.com/JuliaFolds/MicroCollections.jl/blob/{commit}{path}#L{line}",
    sitename = "MicroCollections.jl",
    authors = "Takafumi Arakaki <aka.tkf@gmail.com>",
    strict = true,
)

deploydocs(; repo = "github.com/JuliaFolds/MicroCollections.jl", push_preview = true)
