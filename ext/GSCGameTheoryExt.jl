module GSCGameTheoryExt

using GSC
using GameTheory: AbstractNormalFormGame, NormalFormGame, nums_actions

# Reorder the axes of player i's payoff array from GameTheory's convention
# (i, i+1, ..., N, 1, ..., i-1) to (i, 1, ..., i-1, i+1, ..., N), i.e., own
# action first, opponents' actions in the natural order.
@inline _perm_own(::Val{N}, ::Val{i}) where {N,i} =
    ntuple(Val(N)) do k
        k == 1 && return 1
        j = k - 1 + (k - 1 >= i)  # player on the k-th axis after permuting
        return 1 + mod1(j - i, N)
    end

# Full action profile of an N-player game with `s` as player i's action and
# `t` the opponents' profile in the natural order (1, ..., i-1, i+1, ..., N)
@inline _insert_own(::Val{N}, i, s, t) where {N} =
    ntuple(k -> k < i ? t[k] : k == i ? s : t[k-1], Val(N))

"""
    Game(g::AbstractNormalFormGame)

Construct a `Game` from a normal form game `g` of GameTheory.jl, a
`NormalFormGame` or any `AbstractNormalFormGame`. Strategies are the 1-based
action indices of `g`.
"""
function GSC.Game(g::AbstractNormalFormGame{N}) where N
    players = ntuple(Val(N)) do i
        u(s, t) = g[_insert_own(Val(N), i, s, t)...][i]
        GSC.Player(u, StrategySpace(nums_actions(g)[i]))
    end
    return Game(players)
end

# For a NormalFormGame, one lookup in the player's payoff array
function GSC.Game(g::NormalFormGame{N}) where N
    players = ntuple(Val(N)) do i
        A = PermutedDimsArray(g.players[i].payoff_array,
                              _perm_own(Val(N), Val(i)))
        u(s, t) = A[s, t...]
        GSC.Player(u, StrategySpace(nums_actions(g)[i]))
    end
    return Game(players)
end

"""
    solve(g::AbstractNormalFormGame, algo::Algo, r=0) where {Algo<:GSCAlgorithm}

Return the vector of all pure Nash equilibria of a normal form game `g` of
GameTheory.jl, a `NormalFormGame` or any `AbstractNormalFormGame`, by
algorithm `algo`, as `StrategyProfile`s of action indices. Equivalent to
`solve(Game(g), algo, r)`.
"""
GSC.solve(g::AbstractNormalFormGame, algo::GSCAlgorithm, r::Int=0) =
    solve(Game(g), algo, r)

end
