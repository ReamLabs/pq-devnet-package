"""
Module for launching a Zeam client.
"""

common = import_module("../common.star")

BASE_SERVICE_NAME = "zeam"
DEFAULT_IMAGE = "ethpandaops/zeam:latest"
ENTRYPOINT = "/app/zig-out/bin/zeam"

def initialize(plan, image, index, key_artifact):
    """
    Initialize a Zeam client with given image and index.

    Args:
        plan: The plan object to execute actions.
        image: The Docker image to use for the client.
        index: The index of the participant.
        key_artifact: The name of the files artifact containing the node key.

    Returns:
        The launched service.
    """

    if image == "":
        image = DEFAULT_IMAGE

    service_name = BASE_SERVICE_NAME + "-{}".format(index)

    # Zeam uses scratch base image, so we need to run zeam directly
    # We'll start it with minimal config and configure it properly in start()
    config = ServiceConfig(
        image = image,
        # Run zeam with a sleep loop to keep container alive until properly configured
        cmd = ["sleep", "infinity"],
        ports = {
            "quic": PortSpec(
                number = common.QUIC_PORT,
                transport_protocol = "UDP",
                wait = None,
            ),
            "http": PortSpec(
                number = common.HTTP_PORT,
                transport_protocol = "TCP",
                wait = None,
            ),
            "metrics": PortSpec(
                number = common.METRICS_PORT,
                transport_protocol = "TCP",
                wait = None,
            ),
        },
        files = {
            "/config/keys": key_artifact,
        },
    )
    return plan.add_service(service_name, config)

def start(plan, service, node_index, artifacts_content):
    """
    Start the Zeam client service with the provided genesis artifacts.

    Args:
        plan: The plan object to execute actions.
        service: The service object to start.
        node_index: The index of this node.
        artifacts_content: A struct containing the genesis artifact contents.
    """

    common.create_root_genesis_dir(plan, service)
    common.copy_genesis_content(
        plan,
        service,
        artifacts_content.nodes_yaml,
        "/genesis/nodes.yaml",
    )
    common.copy_genesis_content(
        plan,
        service,
        artifacts_content.validators_yaml,
        "/genesis/validators.yaml",
    )
    common.copy_genesis_content(
        plan,
        service,
        artifacts_content.config_yaml,
        "/genesis/config.yaml",
    )
    common.copy_genesis_content(
        plan,
        service,
        artifacts_content.validator_config_yaml,
        "/genesis/validator-config.yaml",
    )

    # Construct the full command as a single string
    cmd_parts = [
        "--data-dir /data",
        "--custom_genesis /genesis",
        "--validator_config genesis_bootnode",
        "--node-id " + service.name,
        "--node-key /config/keys/node{}.key".format(node_index),
    ]
    full_cmd = " ".join(cmd_parts)

    log_file = common.get_log_file_path(service.name)
    # TODO: Zeam supports logging to a file directly, use that
    plan.exec(
        service_name = service.name,
        recipe = ExecRecipe(
            command = ["nohup " + ENTRYPOINT + " " + full_cmd + " >> " + log_file + " 2>&1 &"],
        ),
        description = "Starting {}".format(service.name),
    )
