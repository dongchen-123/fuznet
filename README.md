# Fuznet

fuznet is an automated fuzzing framework. It generates random netlists then runs them through synthesis tools and checks for discrepancies in the output. 

## Requirements
- Linux-based OS
- Nix package manager
- Vivado installed (Only tested with Vivado 2024.2)
- Python 3

## Installation

Clone and run installer:

```bash
git clone https://github.com/splogdes/fuznet
cd fuznet

./scripts/install_user_service.sh \
    --vivado-path /path/to/vivado \
    --service
```

Installer Options:

| Flag               | Description |
|--------------------|-------------|
| `--vivado-path`    | Path to Vivado installation (e.g. /opt/Xilinx/Vivado/2024.2/bin/vivado) |
| `--service`        | Install fuznet as a user service (recommended) |
| `--workers N`     | Number of worker processes to use |
| `--nice N`     | Set the nice level for worker processes |
| `--restart-sec SEC` | Set the restart delay in seconds for worker processes |
| `--help`           | Show help message |

The script will build fuznet using Nix and set up the necessary environment and start the fuznet service if the `--service` flag is provided.

## Usage

Check service status:

```bash
systemctl --user status fuznet.service
```

View logs:

```bash
journalctl --user -u fuznet.service -f
```

Control the service:

```bash
systemctl --user start|stop|disable fuznet.service
```

## Output

Results are writen to `logs/`:

```bash
logs/
    results.csv
    failed_seeds.log
    seen_netlists.txt
    common/
    rare/
    epic/
    legendary/
    unique_small/
    unique_medium/
    unique_large/
```

Each failing or interesting seed gets its own timestamped directory containing the netlists, logs, and metadata. Temporary directories (tmp-*) are cleaned automatically.

## Uninstallation

To uninstall fuznet and remove the user service, run:

```bash
systemctl --user disable --now fuznet.service
rm ~/.config/systemd/user/fuznet.service
rm -rf ~/fuznet
```