"""
Module for pq-devnet-package: provides the run(plan, args) entrypoint.
"""

input_parser = import_module("./src/utils/input_parser.star")
p2p_key_generator = import_module("./src/p2p_key_generator/p2p_key_generator.star")

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
    node_keys = p2p_key_generator.generate_node_keys(plan, num_participants)
    plan.print("Generated {} node keys".format(len(node_keys)))
