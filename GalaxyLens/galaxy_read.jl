using LensFactory
using JLD2
using GLMakie

# Read the JLD2 file
jldopen("MockLens_20261014.jld2", "r") do data
   # Read data
   model = data["model"]
   optimizer = data["optimizer"]
   chains = data["chains"]
   logL = data["logL"]
   
   # Get free parameter names
   free_params = LensModel.free_parameter_names(model)

   # Get best fit rms
   LensModel.get_best_fit_rms(model, chains, logL)

   # Print GR report
   # LensModel.print_gr_report(chains, param_names=free_params, burn_in=0.4)

   # Time series diagnostics
   # LensModel.time_series_diagnostics(chains, param_names=free_params)

   # Acceptance diagnostics
   # LensModel.acceptance_diagnostics(chains, burn_in=0.4)

   # Corner plot
   fig = LensModel.plot_corner(chains, logL; free_parameter_names=free_params, burn_in=0.2)

   # Plot best model
   fig = LensModel.plot_best_model(model, chains, logL; plot_errors=false)

   # Predict counter-images
   LensModel.predict_image(data, [0.50, 0.17], [0.50, 0.69], 1.5; unit=:arcsec)

   aa = LensModel.get_best_fit_parameters(logL; chains=chains, with_errors=true, print_table=true, free_parameter_names=free_params);
end





