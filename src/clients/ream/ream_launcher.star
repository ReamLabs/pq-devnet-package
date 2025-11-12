"""
Module for launching a Ream client.
"""

common = import_module("../common.star")

BASE_SERVICE_NAME = "ream"
ENTRYPOINT = "/usr/local/bin/ream"

QUIC_PORT = 9000
HTTP_PORT = 5052
METRICS_PORT = 8080

def initialize(plan, image, index, key_artifact):
    """
    Initialize a Ream client with given image and index.

    Args:
        plan: The plan object to execute actions.
        image: The Docker image to use for the client.
        index: The index of the participant.
        key_artifact: The name of the files artifact containing the node key.

    Returns:
        The launched service.
    """

    service_name = BASE_SERVICE_NAME + "-{}".format(index)
    config = ServiceConfig(
        image = image,
        entrypoint = ["/bin/sh", "-c"],
        cmd = common.get_tail_logs_cmd(service_name),
        ports = {
            "quic": PortSpec(
                number = QUIC_PORT,
                transport_protocol = "UDP",
                wait = None,
            ),
            "http": PortSpec(
                number = HTTP_PORT,
                transport_protocol = "TCP",
                wait = None,
            ),
            "metrics": PortSpec(
                number = METRICS_PORT,
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
    Start the Ream client service with the provided genesis artifacts.

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

    log_file = common.get_log_file_path(service.name)
    plan.exec(
        service_name = service.name,
        recipe = ExecRecipe(
            command = ["/bin/sh", "-c", "nohup " + ENTRYPOINT + " " + full_cmd + " >> " + log_file + " 2>&1 &"],
        ),
        description = "Starting {}".format(service.name),
    )
