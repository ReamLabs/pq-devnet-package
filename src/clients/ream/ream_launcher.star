"""
Module for launching a Ream client.
"""

common = import_module("../common.star")

BASE_SERVICE_NAME = "ream"
ENTRYPOINT = "/usr/local/bin/ream"

QUIC_PORT = 9000
HTTP_PORT = 5052
METRICS_PORT = 8080

def initialize(plan, image, index, key_artifact, genesis_artifacts):
    """
    Initialize a Ream client with given image and index.

    Args:
        plan: The plan object to execute actions.
        image: The Docker image to use for the client.
        index: The index of the participant.
        key_artifact: The name of the files artifact containing the node key.
        genesis_artifacts: A struct containing the genesis artifact names (will be created later).

    Returns:
        The launched service.
    """

    service_name = BASE_SERVICE_NAME + "-{}".format(index)
    config = ServiceConfig(
        image = image,
        entrypoint = ["/bin/sh", "-c"],
        cmd = common.DUMMY_CMD,
        # ports = {
        #     "quic": PortSpec(
        #         number = QUIC_PORT,
        #         transport_protocol = "UDP",
        #     ),
        #     "http": PortSpec(
        #         number = HTTP_PORT,
        #         transport_protocol = "TCP",
        #     ),
        #     "metrics": PortSpec(
        #         number = METRICS_PORT,
        #         transport_protocol = "TCP",
        #     ),
        # },
        files = {
            "/config/keys": key_artifact,
            "/genesis": Directory(
                artifact_names = [
                    genesis_artifacts.network_config,
                    genesis_artifacts.validators_yaml,
                    genesis_artifacts.nodes_yaml,
                    genesis_artifacts.genesis_ssz,
                    genesis_artifacts.genesis_json,
                ],
            ),
        },
    )
    return plan.add_service(service_name, config)

def start(plan, service, node_index):
    """
    Start the Ream client service with the provided genesis artifacts.

    Args:
        plan: The plan object to execute actions.
        service: The service object to start.
        node_index: The index of this node.
    """

    # Construct the full command as a single string
    cmd_parts = [
        "--data-dir /data",
        "lean_node",
        "--network /genesis/config.yaml",
        "--validator-registry-path /genesis/validators.yaml",
        "--node-id " + service.name,
        "--private-key-path /config/keys/node{}.key".format(node_index),
        "--socket-address " + service.ip_address,
        "--socket-port " + str(QUIC_PORT),
        "--http-address 0.0.0.0",
        "--http-port " + str(HTTP_PORT),
        "--http-allow-origin",
        "--bootnodes /genesis/nodes.yaml",
        "--metrics",
        "--metrics-address 0.0.0.0",
        "--metrics-port " + str(METRICS_PORT),
    ]
    full_cmd = " ".join(cmd_parts)

    plan.exec(
        service_name = service.name,
        recipe = ExecRecipe(
            command = ["/bin/sh", "-c", "nohup " + ENTRYPOINT + " " + full_cmd + " >/dev/null 2>&1 &"],
        ),
        description = "Starting {} with genesis files".format(service.name),
    )
