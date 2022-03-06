#! /bin/bash
hugoVer="$(hugo version | sed -n -e 's/hugo.v\([[:digit:]]\+\.[[:digit:]]\+\.[[:digit:]]\+\)-.*/\1/p')"

for i in .github/workflows/*-hugo*.yml; do
    yq -i "(.jobs.deploy.steps.[] | select( .id == \"install\")).with.hugo-version = \"$hugoVer\"" $i
done
