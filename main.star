"""
Module for pq-devnet-package: provides the run(plan, args) entrypoint.
"""

input_parser = import_module("./src/utils/input_parser.star")

def run(plan, args = {}):
    """
    Entrypoint for pq-devnet-package.

    Args:
        plan: The plan object to execute actions.
        args: A dictionary of input arguments.
    """
    args_with_right_defaults = input_parser.input_parser(args)

    num_participants = 0
    for participant in args_with_right_defaults["participants"]:
        num_participants += participant.get("count", 1)

    plan.print("Running pq-devnet-package with {} participants".format(num_participants))
