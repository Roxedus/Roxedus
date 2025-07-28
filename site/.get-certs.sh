#!/usr/bin/env bash

set -euo pipefail

credly_user_id="69d2eb01-741c-4a20-a5c7-c433bcf45ae1"
ms_transaction_id="dw58xbyk83q936p"

tmp_dir=$(mktemp -d)

# Fetch Credly badges

curl -sS "https://www.credly.com/users/$credly_user_id/badges?page=1&page_size=100" \
    -H 'accept: application/json' \
    -o "$tmp_dir/badges.json"

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
-o y "$tmp_dir/badges.json" > "$tmp_dir/credly-badges.yml"

declare -A vanity_url

for i in $(yq '.accomplishments | unique_by(.organization.url) | .[].organization.url' "$tmp_dir/credly-badges.yml"); do
    vanity_url[$i]="$(curl -sS ${i} \
        -H 'accept: application/json' | yq '.data.website_url' -)"
done

for i in ${!vanity_url[@]}; do
    yq -i '.accomplishments[] |= select(.organization.url == "'$i'") |= .organization.url = "'${vanity_url[$i]}'"' "$tmp_dir/credly-badges.yml"
done

# Fetch Microsoft certifications

curl -sS 'https://learn.microsoft.com/api/catalog?type=certifications,mergedCertifications' \
    -H 'accept: application/json' \
    -o "$tmp_dir/ms-catalog.json"

curl -sS "https://learn.microsoft.com/api/profiles/transcript/share/$ms_transaction_id" \
    -H 'accept: application/json' \
    -o "$tmp_dir/ms-transcript.json"

yq '.certificationData.activeCertifications[] |= {
    "name": .name,
    "timeline":
        (
        "\(.dateEarned | format_datetime(\"January 2006\")) - \(.expiration // (0 | from_unix ) | format_datetime(\"January 2006\"))"
        | sub(" - January 1970", "")
        ),
    "organization": {
        "name": "Microsoft",
        "url": "https://learn.microsoft.com"
        }
    } | [.certificationData.activeCertifications[]] | {"ms": . } | .' \
-o y "$tmp_dir/ms-transcript.json" > "$tmp_dir/ms-badges.yml"

ms_user=$(yq  -r '.docsId ' "$tmp_dir/ms-transcript.json")
export ms_username=$(yq  -r '.userName ' "$tmp_dir/ms-transcript.json")

readarray ms_certs < <(yq -r '.certificationData.activeCertifications[].name' "$tmp_dir/ms-transcript.json")

for i in ${!ms_certs[@]}; do
    export cert="${ms_certs[$i]%$'\n'}"
    uid="$(yq -r '.certifications[] | select(.title == strenv(cert)) | .uid' $tmp_dir/ms-catalog.json)"
    credential_id=$(curl -sS "https://learn.microsoft.com/api/credentials/credential?sourceType=Certification&sourceUid=${uid}&userId=${ms_user}" \
        -H 'accept: application/json' | yq -r '.credentialId' - )
    export certification_url="https://learn.microsoft.com/en-us/users/${ms_username}/credentials/${credential_id}"
    yq -i '(.ms[] | select(.name == strenv(cert))).certificateURL = strenv(certification_url)' "$tmp_dir/ms-badges.yml"
done

# Merge Credly and Microsoft badges
# https://mikefarah.gitbook.io/yq/operators/multiply-merge#merge-deeply-merging-arrays
idPath=".name"  originalPath=".accomplishments"  otherPath=".ms" yq eval-all '
(
  (( (eval(strenv(originalPath)) + eval(strenv(otherPath)))  | .[] | {(eval(strenv(idPath))):  .}) as $item ireduce ({}; . * $item )) as $uniqueMap
  | ( $uniqueMap  | to_entries | .[]) as $item ireduce([]; . + $item.value)
) as $mergedArray
| select(fi == 0) | (eval(strenv(originalPath))) = $mergedArray
' "$tmp_dir/credly-badges.yml" "$tmp_dir/ms-badges.yml" > badges.yml

# Write accomplishments

i18n=("en" "no")

for i in ${i18n[@]}; do
    yq -i '.accomplishments *= load("badges.yml").accomplishments' "data/${i}/sections/accomplishments.yaml"
    if [ $i != "en" ]; then
        yq -i 'del(.accomplishments[].courseOverview)' "data/${i}/sections/accomplishments.yaml"
    fi
done