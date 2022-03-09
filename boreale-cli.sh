# Runs the CLI inside the running app
args=$(printf "\"%s\", \"%s\"" $1 $2)
/opt/boreale/bin/boreale rpc "Boreale.Tasks.Cli.run([""$args""])"
