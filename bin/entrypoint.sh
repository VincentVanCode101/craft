#!/usr/bin/env sh
set -e

echo "=================================================="
echo "Running ShellCheck recursively on all *.sh files in /workdir:"
# Find all *.sh files recursively and pass them to shellcheck with -x to follow sourced files.
# The -print0 and -0 options ensure proper handling of filenames with spaces.
find /workdir -type f -name '*.sh' -print0 | xargs -0 shellcheck -x -P /workdir/lib:/workdir

echo "=================================================="
echo "ShellCheck completed successfully."
