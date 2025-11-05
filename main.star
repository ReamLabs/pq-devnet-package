"""
Module for pq-devnet-package: provides the run(plan, args) entrypoint.
"""

clients_launcher = import_module("./src/clients/launcher.star")
input_parser = import_module("./src/utils/input_parser.star")

genesis_generator = import_module("./src/setup/genesis_generator.star")
p2p_key_generator = import_module("./src/setup/p2p_key_generator.star")
validator_config_generator = import_module("./src/setup/validator_config_generator.star")

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

    # Warm up network config artifact
    genesis_generator.warm_artifacts(plan)

    # Prelaunch clients and get their services
    # Pass the genesis artifact names so they can be mounted (as future references)
    services = clients_launcher.prelaunch(
        plan,
        args_with_right_defaults["participants"],
        keys_result.artifacts,
        genesis_generator.GENESIS_ARTIFACTS,
    )

    # Generate validator-config.yaml
    validator_config_generator.generate_validator_config(
        plan,
        services,
        keys_result.keys,
    )

    # Run the genesis generator to produce genesis artifacts
    genesis_generator.run_genesis_generator(plan)

    # Run the clients with the generated genesis artifacts
    clients_launcher.launch(plan, services)
