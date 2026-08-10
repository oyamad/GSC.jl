using Documenter, GSC, GameTheory

const GSCGameTheoryExt = Base.get_extension(GSC, :GSCGameTheoryExt)

DocMeta.setdocmeta!(GSC, :DocTestSetup, :(using GSC); recursive=true)

makedocs(;
    modules=[GSC, GSCGameTheoryExt],
    sitename="GSC.jl",
    format=Documenter.HTML(; edit_link="main"),
    repo=Remotes.GitHub("ytrakita", "GSC.jl"),
    pages=[
        "Home" => "index.md",
        "API" => [
            "GSC" => "api.md",
            "GameTheory.jl extension" => "ext.md",
        ],
    ],
)

deploydocs(;
    repo="github.com/ytrakita/GSC.jl",
    devbranch="main",
)
