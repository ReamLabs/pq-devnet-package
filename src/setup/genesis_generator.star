"""
Genesis generator module using pk910's tool.
"""

def run_genesis_generator(plan):
    # TODO

def create_network_config(plan):
    """
    Creates a config.yaml file.

    Args:
        plan: The plan object to execute actions.

    Returns:
        The name of the files artifact containing config.yaml
    """

    # Get genesis time dynamically
    genesis_time = get_genesis_time(plan)

    artifact_name = plan.render_templates(
        config = {
            "/genesis/config.yaml": struct(
                template = """# Genesis Settings
GENESIS_TIME: {{.GenesisTime}}

# Validator Settings
VALIDATOR_COUNT: {{.ValidatorCount}}
""",
                data = {
                    "GenesisTime": genesis_time,
                    "ValidatorCount": 0,
                },
            ),
        },
        name = "network-config",
    )

    plan.print("Created network config (artifact: {})".format(artifact_name))
    return artifact_name

def get_genesis_time(plan, padding = 60):
    """
    Returns a UNIX timestamp after buffer. Defaults to 60 seconds from now.

    Args:
        plan: The plan object to execute actions.
        padding: Number of seconds to add to the current time.

    Returns:
        A UNIX timestamp string (in seconds).
    """

    # Get current Unix timestamp using run_sh
    result = plan.run_sh(
        run = "echo -n $(($(date +%s) + " + str(padding) + "))",
        description = "Getting padded Unix timestamp",
    )
    plan.verify(result.code, "==", 0)
    return result.output
