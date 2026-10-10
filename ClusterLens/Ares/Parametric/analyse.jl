using LensFactory
using JLD2
using GLMakie

# Read the JLD2 file
jldopen("ARES_sample.jld2", "r") do data
   # Read data
   model = data["model"]
   optimizer = data["optimizer"]
   chains = data["chains"]
   logL = data["logL"]

	# Get free parameter names
	free_params = LensModel.free_parameter_names(model)

	# # Corner plot
	# fig = LensModel.plot_corner(chains, logL; free_parameter_names=free_params, burn_in=0.2)

	# Get rms
	LensModel.get_best_fit_rms(model, chains, logL)
	
	# # Plot best fit model vs observations
	# fig = LensModel.plot_best_model(model, chains, logL; plot_errors=false)
	# display(fig)
end