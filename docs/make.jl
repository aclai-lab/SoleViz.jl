using SoleVisualizations
using Documenter

DocMeta.setdocmeta!(SoleVisualizations, :DocTestSetup, :(using SoleVisualizations); recursive=true)

makedocs(;
    modules=[SoleVisualizations],
    authors="Eduard I. STAN, Giovanni PAGLIARINI, Federico MANZELLA",
    repo="https://github.com/aclai-lab/SoleVisualizations.jl/blob/{commit}{path}#{line}",
    sitename="SoleVisualizations.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://aclai-lab.github.io/SoleVisualizations.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/aclai-lab/SoleVisualizations.jl",
    devbranch="main",
)
