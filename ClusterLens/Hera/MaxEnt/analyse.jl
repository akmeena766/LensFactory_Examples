using JLD2
using LensFactory
using GLMakie

# Read the JLD2 file
jldopen("Hera_20261108.jld2", "r") do data
   # Read data
   model = data["model"]
   optimizer = data["optimizer"]
   chains = data["chains"]
   logL = data["logL"]

   best_model, _ = LensModel.get_best_model(model, optimizer)
   # println(best_model)
   
   LensModel.get_best_fit_rms(model, optimizer.kappa)
	
	for i in 1:19
		fig = LensModel.plot_best_model(model, optimizer; source=i, plot_name="$i.png")
	end
end
