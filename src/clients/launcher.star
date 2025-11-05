"""
Module for launching the PQ devnet.
"""

ream_launcher = import_module("./ream/ream_launcher.star")

def prelaunch(plan, participants):
    """
    Prelaunch setup for pq-devnet-package.

    Args:
        plan: The plan object to execute actions.
        participants: A list of participant configurations.

    Returns:
        A list of launched services.
    """

    services = []

    for _, participant in enumerate(participants):
        client_type = participant.get("type")
        client_image = participant.get("image", "")
        client_count = participant.get("count", 1)

        # TODO: Support other client types
        if client_type != "ream":
            continue

        for ii in range(client_count):
            ream_service = ream_launcher.launch(plan, client_image, ii)
            services.append(ream_service)

    return services
