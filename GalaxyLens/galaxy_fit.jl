using LensFactory

# Parse the YAML file
parameters = LensModel.read_input("galaxy_parameter.yaml")
dump(parameters)

# Fit the model
LensModel.fit_model(parameters)