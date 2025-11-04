"""
Utility functions for parsing input arguments.
"""

DEFAULT_ADDITIONAL_SERVICES = []

def input_parser(args):
    # TODO: Add sanity checks for args
    result = default_args(args)
    return result

def default_args(args):
    """
    Fills in default arguments for missing keys in args.

    Args:
        args: A dictionary of input arguments.
    Returns:
        A dictionary with default values filled in.
    """
    if "participants" in args:
        participants = args["participants"]
    else:
        participants = [default_participant()]

    if "network_params" in args:
        network_params = args["network_params"]
    else:
        network_params = default_network_params()

    if "additional_services" in args:
        additional_services = args["additional_services"]
    else:
        additional_services = DEFAULT_ADDITIONAL_SERVICES

    return {
        "participants": participants,
        "network_params": network_params,
        "additional_services": additional_services,
    }

def default_participant():
    return {
        "type": "ream",
        "image": "",
        "count": 4,
    }

def default_network_params():
    return {
        "num_validator_keys_per_node": 1,
        "genesis_delay": 60,
        "genesis_time": 0,
    }
