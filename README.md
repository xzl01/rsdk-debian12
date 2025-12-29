# rsdk-debian12

Offline Docker image package for Debian 12, providing a pre-built Debian 12 container image for offline use.

## Installation

Download the latest `.deb` package from the [Releases](https://github.com/xzl01/rsdk-debian12/releases) page.

Install with:

```bash
sudo dpkg -i rsdk-debian12_*.deb
```

Or install with dependencies:

```bash
sudo apt install ./rsdk-debian12_*.deb
```

## Usage

After installation, the `run-rsdk-debian12` command is available.

Run the container:

```bash
run-rsdk-debian12
```

This starts an interactive Debian 12 container with minimal mounts (network config, timezone, home directory). The prompt will show `[rsdk]` to indicate you are in the container.

### Installing rsdk inside the container

Once inside the container, you can install rsdk (Radxa SDK) using the bundled script:

```bash
install-rsdk.sh
```

To use Chinese mirrors for faster downloads:

```bash
install-rsdk.sh -c
```

This will install the rsdk package and set up the environment for development.

Options:

- `--name NAME`: Set container name
- `--`: Pass additional args to `docker run`

Example:

```bash
run-rsdk-debian12 --name my-container -- bash -c "echo hello"
```

## Building from Source

Clone the repository:

```bash
git clone https://github.com/xzl01/rsdk-debian12.git
cd rsdk-debian12
```

Build the Debian package:

```bash
make deb
```

This requires Docker and build dependencies. The package will be in `../rsdk-debian12_*.deb`.

## CI/CD

GitHub Actions automatically builds amd64 and arm64 packages on push to main branch, and creates releases.

## License

See debian/copyright for details.
