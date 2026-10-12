using GSC, GameTheory

# The game in examples/echenique.jl, defined by its payoff function as a
# GameTheory.AbstractNormalFormGame: a 2-player game on the grid
# {1/K, ..., 1}, with player i's payoff u(s, t) at own action s and the
# opponent's action t
struct EcheniqueGame{T<:Real} <: AbstractNormalFormGame{2,Float64}
    α::Vector{T}
    β::Vector{T}
    K::Int
end

GameTheory.nums_actions(g::EcheniqueGame) = (g.K, g.K)

function GameTheory.payoff_profile(g::EcheniqueGame, a)
    (; α, β, K) = g
    u(s, t, i) = begin
        c = -(α[i] / 10) * (s - t)^2 + 200 * β[i] * sin(100 * s)
        d = ((1 - α[i]) * s * (1 + t) - (1 / 2 - β[i]) * s^2 / 100)
        return c + d / 100
    end
    x = (a[1] / K, a[2] / K)
    return (u(x[1], x[2], 1), u(x[2], x[1], 2))
end

function simulate(K)
    α = rand(2)
    β = rand(2)
    g = EcheniqueGame(α, β, K)

    println("")
    @time e1 = solve(g, BruteForce())
    @time e2 = solve(g, ItrIBR())
    @time e3 = pure_nash(g)
    @show issetequal(e1, e2), issetequal(Tuple.(getfield.(e2, :data)), e3),
          length(e1)

    return
end

function main()
    R = 10
    K = 1000
    for i in 1:R
        simulate(K)
    end
    return
end
