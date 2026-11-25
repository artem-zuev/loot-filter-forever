#!/usr/bin/env bash
set -euo pipefail

tag=${1:?usage: release.sh <tag>   (DRY_RUN=1 builds the zip and uploads nothing)}
fail() { echo "::error::$*" >&2; exit 1; }
sha() { (sha256sum "$1" 2>/dev/null || shasum -a 256 "$1") | cut -d' ' -f1; }

shopt -s nullglob
tocs=(*/*.toc)
[ ${#tocs[@]} -eq 1 ] || fail "expected one addon folder with a .toc, found ${#tocs[@]}: ${tocs[*]}"
toc=${tocs[0]}
addon=${toc%%/*}
field() { sed -n "s/^## $1: *//p" "$toc" | tr -d '\r'; }
version=$(field Version)
interface=$(field Interface)
project=$(field X-Curse-Project-ID)
release=${tag#v}

case "$release" in
  "$version" | "$version"-*) ;;
  *) fail "tag $tag does not match ## Version $version" ;;
esac
case "$release" in
  *-alpha*) type=alpha ;;
  *-beta*) type=beta ;;
  *) type=release ;;
esac

changelog=$(awk -v h="## [$version]" '/^## \[/ { p = index($0, h) == 1; next } p' CHANGELOG.md)
[ -n "$changelog" ] || fail "no CHANGELOG.md section for $version"

zip="$addon-$release.zip"
build() { rm -f "$zip"; zip -qr "$zip" "$addon" -x '*.DS_Store'; }

if [ -n "${DRY_RUN:-}" ]; then
  build
  echo "dry run: $zip sha256 $(sha "$zip") type $type"
  exit 0
fi

[ -n "$project" ] || fail "## X-Curse-Project-ID is empty: create the CurseForge project by hand first"
[ -n "${CF_API_TOKEN:-}" ] || fail "CF_API_TOKEN is not set"

if gh release view "$tag" >/dev/null 2>&1; then
  gh release download "$tag" --pattern "$zip" --clobber ||
    fail "release $tag exists without $zip: delete the release and re-run"
else
  build
  prerelease=""
  [ "$type" = release ] || prerelease=--prerelease
  gh release create "$tag" "$zip" --title "$release" --notes "$changelog" $prerelease
fi

notes=$(gh release view "$tag" --json body --jq .body)
file_id=$(printf '%s\n' "$notes" | sed -n 's/^CurseForge file ID: //p')
if [ -z "$file_id" ]; then
  api=https://wow.curseforge.com/api
  game_version=$(curl -sS --fail-with-body -H "X-Api-Token: $CF_API_TOKEN" "$api/game/versions" |
    jq --arg i "$interface" '[.[] | select(.gameVersionTypeID == 88568 and .apiVersion == $i) | .id][0] // empty')
  [ -n "$game_version" ] || fail "CurseForge has no WoW Forever version for interface $interface"
  metadata=$(jq -n --arg cl "$changelog" --arg name "$release" --arg type "$type" --argjson gv "$game_version" \
    '{changelog: $cl, changelogType: "markdown", displayName: $name, gameVersions: [$gv], releaseType: $type}')
  file_id=$(curl -sS --fail-with-body -H "X-Api-Token: $CF_API_TOKEN" \
    --form-string "metadata=$metadata" -F "file=@$zip" \
    "$api/projects/$project/upload-file" | jq -r '.id // empty')
  [ -n "$file_id" ] || fail "CurseForge accepted the upload but returned no file ID"
  gh release edit "$tag" --notes "$notes

CurseForge file ID: $file_id"
fi

commit=$(git rev-parse --short HEAD 2>/dev/null || echo none)
summary="$addon $release ($type) · commit $commit · $zip sha256 $(sha "$zip") · CurseForge file ID $file_id"
echo "$summary"
[ -z "${GITHUB_STEP_SUMMARY:-}" ] || echo "$summary" >> "$GITHUB_STEP_SUMMARY"
