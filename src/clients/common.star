"""
Common constants and utilities for clients.
"""

DUMMY_CMD = ["sleep 99999"]

def create_root_genesis_dir(plan, service):
    """
    Create the root genesis directory.

    Args:
        plan: The plan object to execute actions.
        service: The service object to create the directory in.
    """

    plan.exec(
        service_name = service.name,
        recipe = ExecRecipe(
            command = ["/bin/sh", "-c", "mkdir -p /genesis"],
        ),
        description = "Creating root genesis directory",
    )

def copy_genesis_content(plan, service, content, target_path):
    """
    Copy the given genesis content into the specified path inside the service.

    Args:
        plan: The plan object to execute actions.
        service: The service object to copy genesis contents into.
        content: The genesis content to write.
        target_path: The target file path inside the service.
    """

    plan.exec(
        service_name = service.name,
        recipe = ExecRecipe(
            command = ["/bin/sh", "-c", "echo '{}' > {}".format(content, target_path)],
        ),
        description = "Copying genesis content to {}".format(target_path),
    )
