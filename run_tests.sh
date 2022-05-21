#!/usr/bin/sh
exec nix-shell --run "poetry install && poetry run pytest"
