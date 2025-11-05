"""
Validator Config Generator Module
Generates validator-config.yaml for the network participants.
"""

def generate_validator_config(plan, participants, node_keys):
    """
    Generates a validator-config.yaml file based on participants and their node keys.

    Args:
        plan: The plan object to execute actions.
        participants: List of participant configurations from args
        node_keys: List of generated private keys (32-byte hex strings)

    Returns:
        The name of the files artifact containing validator-config.yaml
    """

    # Build the validator entries as structured data
    validators_list = []
    key_index = 0

    for participant in participants:
        participant_name = participant.get("type", "unknown_client")
        participant_count = participant.get("count", 1)

        for _ in range(participant_count):
            validator_entry = {
                "name": "{}_{}".format(participant_name, key_index),
                "privkey": node_keys[key_index].strip(),
                "ip": "${KURTOSIS_IP_ADDR_PLACEHOLDER}",
                "quic": 9000 + key_index,
                "seq": 1,
                "count": 1,
            }

            validators_list.append(validator_entry)
            key_index += 1

    # Create the template data
    template_data = {
        "Shuffle": "roundrobin",
        "Validators": validators_list,
    }

    # Render the template
    artifact_name = plan.render_templates(
        config = {
            "/genesis/validator-config.yaml": struct(
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
