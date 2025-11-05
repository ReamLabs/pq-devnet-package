"""
P2P Key Generator Module
Generates node keys for participants in a P2P network.
"""

ENTRYPOINT_ARGS = [
    "sleep",
    "99999",
]
OPENSSL_IMAGE = "alpine/openssl"
SERVICE_NAME = "openssl-service"
SUCCESSFUL_EXEC_CMD_EXIT_CODE = 0

def generate_node_keys(plan, num_participants):
    """
    Generates a list of node keys.

    Args:
        plan: The plan object to execute actions.
        num_participants: The number of participants to generate keys for.
    Returns:
        A list of generated node keys. (32-byte random hex strings)
    """

    plan.add_service(
        SERVICE_NAME,
        ServiceConfig(
            image = OPENSSL_IMAGE,
            entrypoint = ENTRYPOINT_ARGS,
        ),
    )

    node_keys = []
    for _ in range(num_participants):
        result = plan.exec(
            service_name = SERVICE_NAME,
            description = "Generate 32-byte random hex string for node key",
            recipe = ExecRecipe(
                command = ["openssl", "rand", "-hex", "32"],
            ),
        )
        plan.verify(result["code"], "==", SUCCESSFUL_EXEC_CMD_EXIT_CODE)
        node_key = result["output"].strip()
        node_keys.append(node_key)

    return node_keys
