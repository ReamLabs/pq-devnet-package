"""
Module for launching a Ream client.
"""

common = import_module("../common.star")

BASE_SERVICE_NAME = "ream"

def launch(plan, image, index):
    """
    Launch a Ream client.

    Args:
        plan: The plan object to execute actions.
        image: The Docker image to use for the client.
        index: The index of the participant.

    Returns:
        The launched service.
    """

    service_name = BASE_SERVICE_NAME + "-{}".format(index)
    config = ServiceConfig(
        image = image,
        entrypoint = ["/bin/sh", "-c"],
        cmd = common.DUMMY_CMD,
    )
    return plan.add_service(service_name, config)
