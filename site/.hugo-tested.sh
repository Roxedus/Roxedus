#!/usr/bin/env bash
hugoVer="$(hugo version | sed -n -e 's/hugo.v\([[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\)-.*/\1/p')"
nodeVer="$(node -v)"
nodeVer="${nodeVer#*v}"

echo "Updating Hugo version to $hugoVer in GitHub workflows"
echo "Updating Node.js version to $nodeVer in GitHub workflows"


for i in .github/workflows/*-hugo*.yml; do
    yq -i "(.jobs.deploy.steps.[] | select( .id == \"install\")).with.hugo-version = \"$hugoVer\"" $i
    yq -i "(.jobs.deploy.steps.[] | select( .id == \"setup-node\")).with.node-version = \"$nodeVer\"" $i
done
