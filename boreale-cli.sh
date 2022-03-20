#!/usr/bin/env bash

# Runs the CLI inside a new app instance
args="$*"
/opt/boreale/bin/boreale eval "Boreale.Tasks.Cli.run(\"$args\")"
