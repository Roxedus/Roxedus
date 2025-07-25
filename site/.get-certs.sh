#!/usr/bin/env bash

set -euo pipefail

curl 'https://www.credly.com/users/69d2eb01-741c-4a20-a5c7-c433bcf45ae1/badges?page=1&page_size=100' -sS \
    -H 'accept: application/json' \
    -o 'badges.json'

yq '.data[] |= {
    "name": .badge_template.name,
    "courseOverview": .badge_template.description,
    "certificateURL": "https://www.credly.com/badges/\(.id)",
    "timeline":
        (
        "\(.issued_at | format_datetime(\"January 2006\")) - \(.expires_at // (0 | from_unix ) | format_datetime(\"January 2006\"))"
        | sub(" - January 1970", "")
        ),
    "organization": {
        "name": .issuer.entities[0].entity.name,
        "url": (
            .issuer.entities[0].entity.vanity_url
            | sub("/org/", "/organizations/")
            )
        }
    } | [.data[]] | {"accomplishments": . } | .' \
-o y badges.json > badges.yml

declare -A vanity_url

for i in $(yq '.accomplishments | unique_by(.organization.url) | .[].organization.url' badges.yml); do
    vanity_url[$i]="$(curl -sS ${i} \
        -H 'accept: application/json' | yq '.data.website_url' -)"
done

for i in ${!vanity_url[@]}; do
    yq -i '.accomplishments[] |= select(.organization.url == "'$i'") |= .organization.url = "'${vanity_url[$i]}'"' badges.yml
done

i18n=("en" "no")

for i in ${i18n[@]}; do
    yq -i '.accomplishments *= load("badges.yml").accomplishments' "data/${i}/sections/accomplishments.yaml"
    if [ $i != "en" ]; then
        yq -i 'del(.accomplishments[].courseOverview)' "data/${i}/sections/accomplishments.yaml"
    fi
done