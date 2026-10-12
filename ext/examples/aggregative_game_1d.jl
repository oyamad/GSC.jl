using GSC, GameTheory

# The d = 1 case of the game in examples/multidims.jl, defined by its payoff
# function as a GameTheory.AbstractNormalFormGame: player i's payoff is
# v(x, z) with x own action and z the sum of the others'
struct AggregativeGame1d{N} <: AbstractNormalFormGame{N,Float64}
    θ::Vector{Float64}
    K::Int
end

GameTheory.nums_actions(g::AggregativeGame1d{N}) where {N} =
    ntuple(_ -> g.K, Val(N))

function GameTheory.payoff_profile(g::AggregativeGame1d{N}, a) where {N}
    (; θ, K) = g
    v(x, z, i) = (2 / (N - 1)) * x * z / K^2 - (x / K)^θ[i]
    total = sum(a)
    return ntuple(i -> v(a[i], total - a[i], i), Val(N))
end

function simulate(N, K)
    θ = rand(N) + 1.5 * ones(N)
    g = AggregativeGame1d{N}(θ, K)

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
    N = 3
    K = 100
    for i in 1:R
        simulate(N, K)
    end
    return
end
