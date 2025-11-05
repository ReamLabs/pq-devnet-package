"""
Validator Config Generator Module
Generates validator-config.yaml for the network participants.
"""

QUIC_PORT = 9000

def generate_validator_config(plan, services, node_keys):
    """
    Generates a validator-config.yaml file based on participants and their node keys.

    Args:
        plan: The plan object to execute actions.
        services: List of participant instances.
        node_keys: List of generated private keys (32-byte hex strings)

    Returns:
        The name of the files artifact containing validator-config.yaml
    """

    # Build the validator entries as structured data
    validators_list = []

    for i, service in enumerate(services):
        validators_list.append({
            "name": service.name,
            "privkey": node_keys[i].strip(),
            "ip": service.ip_address,
            "quic": QUIC_PORT,
            "seq": 1,
            "count": 1,
        })

    # Create the template data
    template_data = {
        "Shuffle": "roundrobin",
        "Validators": validators_list,
    }

    # Render the template
    artifact_name = plan.render_templates(
        config = {
            "validator-config.yaml": struct(
                template = """shuffle: {{.Shuffle}}
validators:
{{- range .Validators}}
  - name: "{{.name}}"
    privkey: "{{.privkey}}"
    enrFields:
      ip: "{{.ip}}"
      quic: {{.quic}}
      seq: {{.seq}}
    count: {{.count}}
{{end}}""",
                data = template_data,
            ),
        },
        name = "validator-config",
        description = "Generating validator-config.yaml with {} validators".format(len(node_keys)),
    )

    return artifact_name
