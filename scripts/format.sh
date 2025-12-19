#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git rev-parse --show-toplevel)"
cd "$repo_root"

mapfile -t py_files < <(git ls-files -- '*.py')
if ((${#py_files[@]})); then
    black "${py_files[@]}"
fi

mapfile -t c_files < <(git ls-files -- \
    '*.[ch]' \
    '*.cc' \
    '*.cpp' \
    '*.cxx' \
    '*.hh' \
    '*.hpp')
if ((${#c_files[@]})); then
    clang-format -i "${c_files[@]}"
fi
