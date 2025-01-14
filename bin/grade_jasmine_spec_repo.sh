#!/usr/bin/env bash

set -euo pipefail

errcho() {
  >&2 echo "$@";
}

while [[ $# -gt 0 ]]
  do
    key="$1"
    case $key
      in
      -o|--output)
        output_dir=$(cd "$2"; pwd -P);
        shift
        shift
        ;;
      -r|--repo)
        repo=$2;
        shift
        shift
        ;;
      -b|--branch)
        branch=$2;
        shift
        shift
        ;;
       --)
         shift; break;;
    esac
  done

cd "${BASH_SOURCE%/*}" || exit

errcho "Repos will be output to $output_dir"

# Download submissions
 ../utils/downloadPullRequestRepos.js \
   --output "$tmpdir" \
   --repo "$repo" \
   --branch "$branch" \
   | xargs -I{} tar -xf {} -C "$output_dir"

# Run jasmine console reporter
../utils/gradeJasmineSpecRepo.js \
  --directories "$output_dir" \
  --submissions "$submissions"

# TODO: Empty folder command 