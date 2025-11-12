"""
Common constants and utilities for clients.
"""

# Port definitions
QUIC_PORT = 9000
HTTP_PORT = 5052
METRICS_PORT = 8080

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

def get_log_file_path(service_name):
    """
    Returns the log file path for the given service.
    """
    return "/var/log/" + service_name + ".log"

def get_tail_logs_cmd(service_name):
    """
    Returns the command to tail logs for the given service.
    """

    log_file = get_log_file_path(service_name)
    return ["touch " + log_file + " && tail -f " + log_file]
