using LensFactory

# Parse the YAML file
parameters = LensModel.read_input("HERA_input.yaml")

LensModel.fit_model(parameters)
