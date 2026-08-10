module GSCGameTheoryExt

using GSC
using GameTheory: NormalFormGame

# Reorder the axes of player i's payoff array from GameTheory's convention
# (i, i+1, ..., N, 1, ..., i-1) to (i, 1, ..., i-1, i+1, ..., N), i.e., own
# action first, opponents' actions in the natural order.
@inline _perm_own(::Val{N}, ::Val{i}) where {N,i} =
    ntuple(Val(N)) do k
        k == 1 && return 1
        j = k - 1 + (k - 1 >= i)  # player on the k-th axis after permuting
        return 1 + mod1(j - i, N)
    end

"""
    Game(g::NormalFormGame)

Construct a `Game` from a `GameTheory.NormalFormGame`. Strategies are the
1-based action indices of `g`.
"""
function GSC.Game(g::NormalFormGame{N}) where N
    players = ntuple(Val(N)) do i
        A = PermutedDimsArray(g.players[i].payoff_array,
                              _perm_own(Val(N), Val(i)))
        u(s, t) = A[s, t...]
        GSC.Player(u, StrategySpace(g.nums_actions[i]))
    end
    return Game(players)
end

"""
    solve(g::NormalFormGame, algo::Algo, r=0) where {Algo<:GSCAlgorithm}

Return the vector of all pure Nash equilibria of a `GameTheory.NormalFormGame`
`g`, as `StrategyProfile`s of action indices.
"""
GSC.solve(g::NormalFormGame, algo::GSCAlgorithm, r::Int=0) =
    solve(Game(g), algo, r)

end
