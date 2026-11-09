# Lcurve.jl — L-curve for the MaxEnt fit:  julia -t auto Lcurve.jl
using LensFactory
using JLD2
using CairoMakie
const LM = LensModel

# --------------------------------------------------------------------------------------------------
# Settings
# --------------------------------------------------------------------------------------------------
input_file = "HERA_input.yaml"                    # use a copy with save_runs: false
out_file   = "Hera_Lcurve.jld2"
alphas     = 10.0 .^ range(-2, 3, length = 11)    # log-spaced; area-weighted α (old α=1 at 0.5″ ≈ 4 here)
n_target   = 92                                   # 2 × (65 images − 19 systems), for reference

# --------------------------------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------------------------------
# Copy of the model with a different α (structs are immutable, so rebuild)
function with_alpha(model, α)
   lc     = model.lens_config
   new_lc = LM.LensModelIO.MaxEntLens(lc.multiplane, lc.components, Float64(α), lc.pixels)
   fields = [f === :lens_config ? new_lc : getfield(model, f) for f in fieldnames(typeof(model))]
   return typeof(model)(fields...)
end

# Signed curvature of (x(t), y(t)) on a uniform t grid (central differences, interior points)
function curvature(x, y)
   n = length(x)
   c = fill(NaN, n)
   for i in 2:n-1
      dx  = (x[i+1] - x[i-1]) / 2;  dy  = (y[i+1] - y[i-1]) / 2
      ddx = x[i+1] - 2x[i] + x[i-1]; ddy = y[i+1] - 2y[i] + y[i-1]
      c[i] = (dx * ddy - dy * ddx) / (dx^2 + dy^2)^1.5
   end
   return c
end

# --------------------------------------------------------------------------------------------------
# Fits
# --------------------------------------------------------------------------------------------------
model     = LM.read_input(input_file)
param_ref = Dict(p.key => p.refer for p in model.parameters)

χ2   = fill(NaN, length(alphas))      # −2 log L (source-plane χ²)
negS = fill(NaN, length(alphas))      # entropy deficit −S = −log_prior / α  (≥ 0)
conv = falses(length(alphas))         # run loop converged?
nrun = zeros(Int, length(alphas))
tfit = zeros(length(alphas))

for (i, α) in enumerate(alphas)
   t0  = time()
   res = LM.LensModelFit.run_optimizer(with_alpha(model, α), param_ref, false)
   last = res.runs[end]

   χ2[i]   = -2.0 * last.log_likelihood
   negS[i] = -last.log_prior / α
   conv[i] = res.converged
   nrun[i] = length(res.runs)
   tfit[i] = time() - t0

   println("α = $(round(α, sigdigits = 3)):  χ² = $(round(χ2[i], digits = 2)),  −S = $(round(negS[i], sigdigits = 4)),  ",
           "runs = $(nrun[i]),  converged = $(conv[i]),  $(round(tfit[i], digits = 1)) s")

   # Save after every fit, so an interrupted scan keeps its results
   jldsave(out_file; alphas, χ2, negS, conv, nrun, tfit)
end

# --------------------------------------------------------------------------------------------------
# Corner (maximum curvature in log–log) and plot
# --------------------------------------------------------------------------------------------------
x = log10.(max.(negS, eps()))
y = log10.(χ2)
c = curvature(x, y)
i_corner = argmax(abs.(replace(c, NaN => 0.0)))
println("Max-curvature point: α ≈ $(round(alphas[i_corner], sigdigits = 3)) (check visually)")

fig = Figure(size = (1100, 450))

ax1 = Axis(fig[1, 1]; xlabel = L"-S", ylabel = L"\chi^2", xscale = log10, yscale = log10, title = "L-curve")
lines!(ax1, max.(negS, eps()), χ2; color = :gray)
scatter!(ax1, max.(negS[conv], eps()), χ2[conv]; color = :black, label = "converged")
any(.!conv) && scatter!(ax1, max.(negS[.!conv], eps()), χ2[.!conv]; color = :red, marker = :xcross, label = "not converged")
scatter!(ax1, [max(negS[i_corner], eps())], [χ2[i_corner]]; color = :transparent, strokecolor = :blue,
         strokewidth = 2, markersize = 18, label = "max curvature")
for i in eachindex(alphas)
   text!(ax1, max(negS[i], eps()), χ2[i]; text = "  α=$(round(alphas[i], sigdigits = 2))", fontsize = 10)
end
axislegend(ax1; position = :rt)

ax2 = Axis(fig[1, 2]; xlabel = L"\alpha", ylabel = L"\chi^2", xscale = log10, yscale = log10, title = L"\chi^2(\alpha)")
scatterlines!(ax2, alphas, χ2; color = :black)
hlines!(ax2, [n_target]; color = :blue, linestyle = :dash, label = L"\chi^2 = %$n_target")
axislegend(ax2; position = :lt)

save("Hera_Lcurve.png", fig)
