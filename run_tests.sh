#!/usr/bin/env bash
exec nix-shell --run "poetry install && poetry run pytest"
