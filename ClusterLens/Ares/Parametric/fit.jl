using LensFactory

# Parse the YAML file
parameters = LensModel.read_input("ARES_input.yaml")

LensModel.fit_model(parameters)
