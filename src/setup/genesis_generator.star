"""
Genesis generator module using pk910's tool.
"""

GENESIS_ARTIFACTS = struct(
    genesis_ssz = "genesis-ssz",
    genesis_json = "genesis-json",
    nodes_yaml = "nodes-yaml",
    validators_yaml = "validators-yaml",
    validator_config = "validator-config",
    network_config = "network-config",
)
GENESIS_GENERATOR_IMAGE = "ethpandaops/eth-beacon-genesis:pk910-leanchain"
GENESIS_GENERATOR_SERVICE_NAME = "genesis-generator"
GENESIS_DIR = "/genesis"

def run_genesis_generator(plan, network_params):
    """
    Runs eth-beacon-genesis leanchain to generate genesis files.

    Args:
        plan: The plan object to execute actions.
        network_params: Parameters for the network configuration.

    Returns:
        A list of artifact names containing the generated genesis files.
    """

    create_network_config(plan, network_params)

    plan.run_sh(
        run = (
            "mkdir -p {0} && " +
            "/app/eth-genesis-state-generator leanchain " +
            "--config /network-config/config.yaml " +
            "--mass-validators {0}/validator-config.yaml " +
            "--state-output {0}/genesis.ssz " +
            "--json-output {0}/genesis.json " +
            "--nodes-output {0}/nodes.yaml " +
            "--validators-output {0}/validators.yaml " +
            "--config-output {0}/config.yaml"
        ).format(GENESIS_DIR),
        image = GENESIS_GENERATOR_IMAGE,
        files = {
            "/genesis": GENESIS_ARTIFACTS.validator_config,
            "/network-config": GENESIS_ARTIFACTS.network_config,
        },
        store = [
            StoreSpec(src = GENESIS_DIR + "/genesis.ssz", name = "genesis-ssz"),
            StoreSpec(src = GENESIS_DIR + "/genesis.json", name = "genesis-json"),
            StoreSpec(src = GENESIS_DIR + "/nodes.yaml", name = "nodes-yaml"),
            StoreSpec(src = GENESIS_DIR + "/validators.yaml", name = "validators-yaml"),
            StoreSpec(src = GENESIS_DIR + "/config.yaml", name = "network-config"),
        ],
        description = "Running eth-beacon-genesis leanchain to generate genesis files",
    )

    # Return the names of the generated artifacts
    return struct(
        genesis_ssz = "genesis-ssz",
        genesis_json = "genesis-json",
        nodes_yaml = "nodes-yaml",
        validators_yaml = "validators-yaml",
        network_config = "network-config",
    )

def create_network_config(plan, network_params):
    """
    Creates a config.yaml file.

    Args:
        plan: The plan object to execute actions.

    Returns:
        The name of the files artifact containing config.yaml
    """

    # If genesis_time is explicitly provided, use it
    # Otherwise, use current time + padding
    if network_params.get("genesis_time", 0) != 0:
        genesis_time = int(network_params.get("genesis_time"))
    else:
        # Get genesis time dynamically
        genesis_time = get_genesis_time(plan, padding = network_params.get("genesis_delay", 60))

    artifact_name = plan.render_templates(
        config = {
            "config.yaml": struct(
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
    return result.output
