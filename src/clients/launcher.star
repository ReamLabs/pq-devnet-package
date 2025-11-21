"""
Module for launching the PQ devnet.
"""

ream_launcher = import_module("./ream/ream_launcher.star")
zeam_launcher = import_module("./zeam/zeam_launcher.star")

def prelaunch(plan, participants, keys_artifacts):
    """
    Prelaunch setup for pq-devnet-package.

    Args:
        plan: The plan object to execute actions.
        participants: A list of participant configurations.
        keys_artifacts: A list of key artifact names (one per node).

    Returns:
        A list of launched services.
    """

    services = []
    node_index = 0

    for _, participant in enumerate(participants):
        client_type = participant.get("type")
        client_image = participant.get("image", "")
        client_count = participant.get("count", 1)
        
        # TODO: Add Qlean
        if client_type == "ream":
            launcher = ream_launcher
        elif client_type == "zeam":
            launcher = zeam_launcher
        else:
            plan.print("Unsupported client type: {}".format(client_type))
            continue

        for _ in range(client_count):
            service = launcher.initialize(
                plan,
                client_image,
                node_index,
                keys_artifacts[node_index],
            )
            services.append(service)
            node_index += 1

    plan.print("Prelaunch completed with {} services".format(len(services)))
    for service in services:
        plan.print("Service details: {}".format(service))

    return services

def launch(plan, services, genesis_artifacts):
    """
    Launch the pq-devnet-package clients with actual commands.

    Args:
        plan: The plan object to execute actions.
        services: A list of launched services.
        genesis_artifacts: A struct containing genesis artifact names.
    """

    # Read nodes.yaml from artifacts and copy to /genesis/nodes.yaml
    nodes_yaml_result = plan.run_sh(
        run = "cat /genesis/nodes.yaml",
        files = {
            "/genesis": genesis_artifacts.nodes_yaml,
        },
        description = "Reading nodes.yaml from genesis artifacts",
    )
    validators_yaml_result = plan.run_sh(
        run = "cat /genesis/validators.yaml",
        files = {
            "/genesis": genesis_artifacts.validators_yaml,
        },
        description = "Reading validators.yaml from genesis artifacts",
    )
    config_yaml_result = plan.run_sh(
        run = "cat /genesis/config.yaml",
        files = {
            "/genesis": genesis_artifacts.network_config,
        },
        description = "Reading config.yaml from genesis artifacts",
    )
    validator_config_yaml_result = plan.run_sh(
        run = "cat /genesis/validator-config.yaml",
        files = {
            "/genesis": genesis_artifacts.validator_config,
        },
        description = "Reading validator-config.yaml from genesis artifacts",
    )
    artifacts_content = struct(
        nodes_yaml = nodes_yaml_result.output,
        validators_yaml = validators_yaml_result.output,
        config_yaml = config_yaml_result.output,
        validator_config_yaml = validator_config_yaml_result.output,
    )

    for i, service in enumerate(services):
        client_type = service.name.split("-")[0]

        # TODO: Add Qlean
        if client_type == "ream":
            launcher = ream_launcher
        elif client_type == "zeam":
            launcher = zeam_launcher
        else:
            plan.print("Unsupported client type during launch: {}".format(client_type))
            continue
        launcher.start(plan, service, i, artifacts_content)