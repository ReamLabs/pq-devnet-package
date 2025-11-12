# PQ Devnet Package: A Kurtosis Package for spinning your local devnet up.

A [Kurtosis](kurtosis-repo) package that quickly spins up a new devnet, with easy configuration.

This repository is highly inspired by [ethereum-package](https://github.com/ethpandaops/ethereum-package).

## Quickstart

1. [Install Docker & start the Docker Daemon if you haven't done so already][docker-installation]
2. [Install the Kurtosis CLI, or upgrade it to the latest version if it's already installed][kurtosis-cli-installation]
3. Run the package with default configurations from the command line:
   ```bash
   kurtosis run --enclave my-testnet github.com/ReamLabs/pq-devnet-package
   ```

#### Run with your own configuration

Kurtosis packages are parameterizable, meaning you can customize your network and its behavior to suit your needs by storing parameters in a file that you can pass in at runtime like so:

```bash
kurtosis run --enclave my-testnet github.com/ethpandaops/pq-devnet-package --args-file network_params.yaml
```

Where `network_params.yaml` contains the parameters for your network in your home directory.

## Configuration

```yaml
# List of client participants in the network
participants:
  # Client type (e.g., ream, zeam, qlean)
  - type: ream
    # Docker image to use for this client
    image: ethpandaops/ream:master-0bceaee
    # Number of nodes to spin up for this client type
    count: 4

# Network-level parameters
network_params:
  # The number of validator keys that each CL validator node should get
  num_validator_keys_per_node: 1
  # Time (in seconds) to delay before starting the network after genesis
  genesis_delay: 60
  # Unix timestamp for genesis time (0 = use current time)
  genesis_time: 0

# Additional services to run alongside the network
additional_services:
  # TODO: Support more services
  # - leanview      # Blockchain explorer
  # - grafana       # Monitoring dashboards
  # - prometheus    # Metrics collection
```

## Roadmap

### Client Support
- [ ] Support Zeam client
- [ ] Support Qlean client

### Additional Services
- [ ] Support Leanview (blockchain explorer)
- [ ] Support Prometheus (metrics collection)
- [ ] Support Grafana (monitoring dashboards)

<!------------------------ Only links below here -------------------------------->

[docker-installation]: https://docs.docker.com/get-docker/
[kurtosis-cli-installation]: https://docs.kurtosis.com/install
[kurtosis-repo]: https://github.com/kurtosis-tech/kurtosis
