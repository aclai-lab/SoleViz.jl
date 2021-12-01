using SoleViz
using Documenter

DocMeta.setdocmeta!(SoleViz, :DocTestSetup, :(using SoleViz); recursive=true)

makedocs(;
    modules=[SoleViz],
    authors="Eduard I. STAN, Giovanni PAGLIARINI, Federico MANZELLA",
    repo="https://github.com/aclai-lab/SoleViz.jl/blob/{commit}{path}#{line}",
    sitename="SoleViz.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://aclai-lab.github.io/SoleViz.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/aclai-lab/SoleViz.jl",
    devbranch="main",
)
