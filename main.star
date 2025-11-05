"""
Module for pq-devnet-package: provides the run(plan, args) entrypoint.
"""

clients_launcher = import_module("./src/clients/launcher.star")
input_parser = import_module("./src/utils/input_parser.star")
p2p_key_generator = import_module("./src/p2p_key_generator/p2p_key_generator.star")
validator_config_generator = import_module("./src/validator_config/validator_config_generator.star")

def run(plan, args = {}):
    """
    Entrypoint for pq-devnet-package.

    Args:
        plan: The plan object to execute actions.
        args: A dictionary of input arguments.
    """

    # Parse input arguments and fill in defaults
    args_with_right_defaults = input_parser.input_parser(args)

    num_participants = 0
    for participant in args_with_right_defaults["participants"]:
        num_participants += participant.get("count", 1)

    plan.print("Running pq-devnet-package with {} participants".format(num_participants))

    # Generate N node keys for each participant (32-byte random hex strings)
    keys_result = p2p_key_generator.generate_node_keys(plan, num_participants)
    plan.print("Generated {} node keys".format(len(keys_result.keys)))

    # Print the keys and their artifact locations
    for i, key in enumerate(keys_result.keys):
        plan.print("Node {}: {} (artifact: {})".format(i, key, keys_result.artifacts[i]))

    # Prelaunch clients and get their services
    services = clients_launcher.prelaunch(plan, args_with_right_defaults["participants"])
    plan.print("Pre-launched {} client services".format(len(services)))
    for service in services:
        plan.print("Service details: {}".format(service))

    # Generate validator-config.yaml
    validator_config_artifact = validator_config_generator.generate_validator_config(
        plan,
        services,
        keys_result.keys,
    )
    plan.print("Generated validator-config.yaml (artifact: {})".format(validator_config_artifact))

    # Cat the validator-config.yaml for visibility
    cat_result = plan.run_sh(
        run = "cat /mounted/genesis/validator-config.yaml",
        files = {
            "/mounted": validator_config_artifact,
        },
        description = "Displaying generated validator-config.yaml",
    )
    plan.verify(cat_result.code, "==", 0)
