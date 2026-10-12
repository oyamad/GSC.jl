# GameTheory.jl extension

When [GameTheory.jl](https://github.com/QuantEcon/GameTheory.jl) is loaded,
all pure Nash equilibria of a normal form game from GameTheory.jl can be
computed with `solve` by Echenique's algorithm as implemented by GSC.jl:

```jldoctest
julia> using GSC, GameTheory

julia> g = NormalFormGame(
           [(3, 3) (3, 2) (3, 1) (0, 0)
            (2, 3) (2, 2) (2, 1) (0, 0)
            (1, 3) (1, 2) (1, 1) (0, 0)
            (0, 0) (0, 0) (0, 0) (0, 0)]
       );

julia> solve(g, ItrIBR())
2-element Vector{StrategyProfile{2, Tuple{Int64, Int64}}}:
 (1, 1)
 (4, 4)
```

Strategies are the 1-based action indices of the game.

## Methods

Methods available when GameTheory.jl is loaded.

```@autodocs
Modules = [GSCGameTheoryExt]
```
