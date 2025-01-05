# GE-Proton-Latest

GE-Proton-Latest is a wrapper and update script designed to run as a compatibility tool from Steam. It automatically detects and uses the latest version of GE-Proton available in your Steam's `compatibilitytools.d` directory. The script checks for the newest version and installs it before being used, ensuring you always have the most up-to-date compatibility tool for running games on Steam that require GE-Proton.


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

### Recommended Installation (using curl)

This method is recommended as it is the most efficient and requires no additional steps beyond installing the prerequisites:

```
curl -sL https://raw.githubusercontent.com/ripps818/ge-proton-latest/main/install.sh | bash
```

If you need to specify the location of your Steam configuration directory, you can download the script and use the `-d` flag to specify its location:

```
curl -sL https://raw.githubusercontent.com/ripps818/ge-proton-latest/main/install.sh -o install.sh
bash install.sh -d /path/to/your/steam/config
```

