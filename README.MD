# Ollama Installer (linux)

A Bash script to install or update Ollama on your system.

## Usage

To use this script, save it to a file (e.g. `ollama_installer.sh`) and run it with the following options:

```bash
./ollama_installer.sh [-v <version>]
```

### Options

| Option | Description |
| --- | --- |
| `-v`, `--version` | Specify the version of Ollama to install or update to. |
| `-h`, `--help` | Display the help message. |

### Example

```bash
./ollama_installer.sh -v 0.3.14
```

## Requirements

* A system with curl and Bash installed
* Internet connection to access the Ollama GitHub repository and installation script

## Features

* Detects and prompts to install or update to the latest version of Ollama
* Supports installation of a specific version of Ollama
* Preserves systemd override config (if present) during update
* Restores systemd override config after update

## Installation

1. Clone this repository or save the script to a file (e.g. `ollama_installer.sh`)
2. Make the script executable: `chmod +x ollama_installer.sh`
3. Run the script: `./ollama_installer.sh [-v <version>]`

## Disclaimer

This script is a third-party wrapper around the official Ollama installation script (`https://ollama.com/install.sh`). We are not currently affiliated with [Ollama](https://ollama.com/), and this project is not officially endorsed by them. Use at your own discretion.