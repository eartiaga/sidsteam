Sid-based Steam Docker
======================

This is a steam launcher based on Debian Sid (a.k.a. Unstable), ready
to run in a Docker container.

It expects relatively new NVidia graphic cards (i.e. those supported by
non-legacy NVidia drivers).


Acknowledgments
---------------

This is heavily inspired in other steam-in-a-docker containers, especially:
- https://hub.docker.com/r/andrey01/steam/
- https://hub.docker.com/r/tianon/steam/

For the impatient
-----------------

1. Clone this repository
    git clone https://github.com/eartiaga/sidsteam

2. Go into the repository's root directory
    cd sidsteam

3. Build the image
    docker-compose build

4. Launch the container
    STEAM_USER=$(id -ru) docker-compose up

Configuration
-------------

The container is affected by some environment variables, with default values
defined in the `.env` file in the repository root directory. Environment
variables take precedence over the file. The relevant variables are:

* STEAM_DATADIR: The directory that the Steam launcher will use to store
  local data. It defaults to a directory named `data` in the repository's
  root.

* STEAM_UID: This should be the uid of a user with write permissions on the
  `STEAM_DATADIR` directory. It defaults to `1001` (a convenient value for
  my own setup ;-) (Please, be sensible and avoid the root user and 0777
  permissions...)

* STEAM_USER: The name of the non-root user inside the container. It defaults
  to `steam`, but it can be changed according to taste.

Disclaimer
----------

There might be bugs. Use at your own risk.

