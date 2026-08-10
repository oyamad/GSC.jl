using Documenter, GSC

DocMeta.setdocmeta!(GSC, :DocTestSetup, :(using GSC); recursive=true)

makedocs(;
    modules=[GSC],
    sitename="GSC.jl",
    format=Documenter.HTML(; edit_link="main"),
    repo=Remotes.GitHub("ytrakita", "GSC.jl"),
    pages=[
        "Home" => "index.md",
        "API" => "api.md",
    ],
)

deploydocs(;
    repo="github.com/ytrakita/GSC.jl",
    devbranch="main",
)
