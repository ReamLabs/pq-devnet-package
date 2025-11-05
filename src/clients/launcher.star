"""
Module for launching the PQ devnet.
"""

ream_launcher = import_module("./ream/ream_launcher.star")

def prelaunch(plan, participants, keys_artifacts, genesis_artifacts):
    """
    Prelaunch setup for pq-devnet-package.

    Args:
        plan: The plan object to execute actions.
        participants: A list of participant configurations.
        keys_artifacts: A list of key artifact names (one per node).
        genesis_artifacts: A struct containing genesis artifact names.

    Returns:
        A list of launched services.
    """

    services = []
    node_index = 0

    for _, participant in enumerate(participants):
        client_type = participant.get("type")
        client_image = participant.get("image", "")
        client_count = participant.get("count", 1)

        # TODO: Support other client types
        if client_type != "ream":
            continue

        for _ in range(client_count):
            service = ream_launcher.initialize(
                plan,
                client_image,
                node_index,
                keys_artifacts[node_index],
                genesis_artifacts,
            )
            services.append(service)
            node_index += 1

    plan.print("Prelaunch completed with {} services".format(len(services)))
    for service in services:
        plan.print("Service details: {}".format(service))

    return services

def launch(plan, services):
    """
    Launch the pq-devnet-package clients with actual commands.

    Args:
        plan: The plan object to execute actions.
        services: A list of launched services.
    """

    for i, service in enumerate(services):
        # TODO: Support other client types
        ream_launcher.start(plan, service, i)
