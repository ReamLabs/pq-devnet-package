"""
P2P Key Generator Module
Generates node keys for participants in a P2P network.
"""

OPENSSL_IMAGE = "alpine/openssl"
SUCCESSFUL_EXEC_CMD_EXIT_CODE = 0

def generate_node_keys(plan, num_participants):
    """
    Generates node keys and stores them as individual files artifacts.

    Args:
        plan: The plan object to execute actions.
        num_participants: The number of participants to generate keys for.
    Returns:
        A struct containing:
        - keys: List of generated node keys (32-byte random hex strings)
        - artifacts: List of files artifact names (one per key)
    """

    node_keys = []
    artifacts = []

    for i in range(num_participants):
        result = plan.run_sh(
            run = "mkdir -p /config/keys && \
            openssl rand -hex 32 | tr -d '\\n' > /config/keys/node" +
                  str(i) + ".key && \
            cat /config/keys/node" + str(i) + ".key",
            image = OPENSSL_IMAGE,
            store = [
                StoreSpec(
                    src = "/config/keys/node{}.key".format(i),
                    name = "node-key-{}".format(i),
                ),
            ],
            description = "Generating and storing node key {}".format(i),
        )

        plan.verify(result.code, "==", SUCCESSFUL_EXEC_CMD_EXIT_CODE)
        node_key = result.output.strip()
        node_keys.append(node_key)
        artifacts.append(result.files_artifacts[0])

    return struct(
        keys = node_keys,
        artifacts = artifacts,
    )
