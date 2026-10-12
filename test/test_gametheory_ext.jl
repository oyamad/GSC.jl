using GameTheory: GameTheory, AbstractNormalFormGame, NormalFormGame, pure_nash

# NormalFormGame whose payoff to player i at full action profile a is F(i, a),
# following GameTheory's convention that the axes of player i's payoff array
# correspond to players (i, i+1, ..., N, 1, ..., i-1).
function gt_game(F, nums_actions::NTuple{N,Int}) where N
    players = ntuple(Val(N)) do i
        A = Array{Float64,N}(undef,
                             ntuple(k -> nums_actions[mod1(i + k - 1, N)],
                                    Val(N)))
        for a in CartesianIndices(nums_actions)
            idx = ntuple(k -> a[mod1(i + k - 1, N)], Val(N))
            A[idx...] = F(i, Tuple(a))
        end
        GameTheory.Player(A)
    end
    return NormalFormGame(players)
end

# The same game defined by its payoff function
struct RulesGame{N,F} <: AbstractNormalFormGame{N,Float64}
    F::F
    nums_actions::NTuple{N,Int}
end
GameTheory.nums_actions(g::RulesGame) = g.nums_actions
GameTheory.payoff_profile(g::RulesGame{N}, a) where {N} =
    ntuple(i -> g.F(i, a), Val(N))

# Belhaj-Bramoulle-Deroian (2014) network game, discretized:
# u_i(x) = x_i * (a[i] + lambda * sum_j g[i,j] * x_j) - x_i^2 / 2,
# x_i in {0, L/K, ..., L}.
function bbd_game(g::AbstractMatrix, a::AbstractVector, lambda::Real,
                  L::Real, K::Int, ::Val{N}) where N
    grid = collect(range(0, L, length=K+1))
    players = ntuple(Val(N)) do i
        opponents = ntuple(k -> mod1(i + k, N), Val(N-1))
        payoff_array = Array{Float64,N}(undef, ntuple(_ -> K + 1, Val(N)))
        for I in CartesianIndices(payoff_array)
            x = grid[I[1]]
            s = sum(g[i, opponents[k]] * grid[I[k+1]] for k in 1:N-1)
            payoff_array[I] = x * (a[i] + lambda * s) - x^2 / 2
        end
        GameTheory.Player(payoff_array)
    end
    return NormalFormGame(players)
end

# The same game defined by its payoff function
struct BBDGame{N,TG<:AbstractMatrix,TA<:AbstractVector} <:
        AbstractNormalFormGame{N,Float64}
    g::TG
    a::TA
    lambda::Float64
    grid::Vector{Float64}
end
BBDGame(g, a, lambda, L, K, ::Val{N}) where {N} =
    BBDGame{N,typeof(g),typeof(a)}(g, a, lambda, collect(range(0, L, length=K+1)))
GameTheory.nums_actions(g::BBDGame{N}) where {N} =
    ntuple(_ -> length(g.grid), Val(N))
function GameTheory.payoff_profile(g::BBDGame{N}, a) where {N}
    x = ntuple(j -> g.grid[a[j]], Val(N))
    return ntuple(Val(N)) do i
        s = sum(g.g[i, j] * x[j] for j in 1:N)
        x[i] * (g.a[i] + g.lambda * s) - x[i]^2 / 2
    end
end

@testset "GSCGameTheoryExt" begin
    @testset "Conversion, $N players" for N in 2:5
        # Distinct action counts, so that axis mixups throw or mismatch
        nums = ntuple(j -> j + 1, N)
        F(i, a) = sum(a[j] * 10.0^(j-1) for j in 1:N) + 1000.0 * i
        for G in (@inferred(Game(gt_game(F, nums))),
                  @inferred(Game(RulesGame(F, nums))))
            @test all(
                G[i](a[i], StrategyProfile(m -> a[m + (m >= i)], N-1)) ==
                    F(i, Tuple(a))
                for a in CartesianIndices(nums), i in 1:N
            )
        end
    end

    @testset "BBD network game" begin
        # Complete graph on 3 players; the continuum game has exactly three
        # equilibria, all on the grid for K a multiple of 60:
        # (11, 10, 0)/60, (23, 22, 3)/60, (60, 60, 60)/60.
        K = 60
        nfg = bbd_game([0 1 1; 1 0 1; 1 1 0], [0.05, 0.02, -0.55], 0.8, 1, K,
                       Val(3))

        # In 1-based indices; includes discretization-induced equilibria
        # near the smallest continuum equilibrium
        E = [(10, 9, 1), (11, 10, 1), (12, 11, 1), (13, 12, 1), (14, 13, 1),
             (24, 23, 4), (61, 61, 61)]

        @test issetequal(pure_nash(nfg), E)
        @test issetequal(
            [Tuple(e.data) for e in @inferred solve(nfg, BruteForce())], E)
        # solve with ItrIBR is not inference-clean in GSC itself
        @test issetequal(
            [Tuple(e.data) for e in solve(nfg, ItrIBR())], E)

        # The same game defined by its payoff function, with no payoff array
        rules = BBDGame([0 1 1; 1 0 1; 1 1 0], [0.05, 0.02, -0.55], 0.8, 1, K,
                        Val(3))
        @test issetequal(
            [Tuple(e.data) for e in @inferred solve(rules, BruteForce())], E)
        @test issetequal(
            [Tuple(e.data) for e in solve(rules, ItrIBR())], E)
    end
end
