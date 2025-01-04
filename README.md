# GE-Proton-Latest

Wrapper and update script to run as a compatibility tool from steam. The wrapper script checks for the newest version of GE-Proton in your Steam's compatibilitytools.d and uses it. Before the wrapper starts proton, it will automatically check if a new version of GE-Proton is available from GlouriousEggroll and install the newest version in compatibilitytools.d so that at the wrapper can use it. This also allows you to manually select the newly installed version if you don't want keep using the older version (might need to restart steam for new version to be detected). 


## Features

*   Automatic detection of the Steam installation directory.
*   Download and checksum verification of the latest GE-Proton release.
*   Installation into the correct Steam compatibility tools directory.
*   Dynamic selection of the highest available GE-Proton version.


## Requirements

*   `curl`: For downloading files from the internet.
*   `tar`: For extracting the GE-Proton archive.
*   `find`, `sort`, `tail`, `tr`: standard linux utilities.


## Installation

**Recommended Installation (using curl):**

This installation method is recommended as it is the most efficient and requires no additional steps beyond installing prerequisites:

```bash
curl -sL https://raw.githubusercontent.com/ripps818/ge-proton-latest/main/install.sh | bash
```

If you need to specify where your steam configuration directory is, you may download the script and use `-d` flag to specify it's location.
