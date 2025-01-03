# ge-proton-latest

This script simplifies the process of installing and managing Glorious Eggroll's GE-Proton versions within your Steam compatibility tools directory. It downloads the latest GE-Proton release from GitHub, verifies its integrity, and installs it automatically, selecting the highest version available. This repository also includes a wrapper script for launching games with the selected GE-Proton.


## Features

*   Automatic detection of the Steam installation directory.
*   Download and checksum verification of the latest GE-Proton release.
*   Installation into the correct Steam compatibility tools directory.
*   Dynamic selection of the highest available GE-Proton version.


## Requirements

*   `curl`: For downloading files from the internet.
*   `jq`: For parsing JSON data (available via most package managers: `apt-get install jq`, `yum install jq`, etc.).
*   `tar`: For extracting the GE-Proton archive.
*   `find`, `sort`, `tail` standard linux utilities.


## Installation

**Recommended Installation (using curl):**

This installation method is recommended as it is the most efficient and requires no additional steps beyond installing prerequisites:

```bash
curl -sL https://raw.githubusercontent.com/ripps818/ge-proton-latest/main/install.sh | bash
