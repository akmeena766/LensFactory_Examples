using LensFactory

# Parse the YAML file
parameters = LensModel.read_input("HERA_input.yaml")
dump(parameters)

# LensModel.fit_model(parameters)
