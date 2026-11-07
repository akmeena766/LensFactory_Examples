using JLD2
using LensFactory
using GLMakie

# Read the JLD2 file
jldopen("Hera_20261107.jld2", "r") do data
   # Read data
   model = data["model"]
   optimizer = data["optimizer"]
   chains = data["chains"]
   logL = data["logL"]

   best_lens, _ = LensModel.get_best_model(model, optimizer)
	
	gx, gy = Lenses.get_meshgrid(100, 100, 2.0)
	
	kappa, gamma1, gamma2 = Lenses.get_kappa_gamma(best_lens, gx, gy, 1.0)
	println(kappa)
	fig, ax = Lenses.plot_sky(100, 100)
	heatmap!(ax, gx[:, 1], gy[1, :], kappa)
	display(fig)
end
