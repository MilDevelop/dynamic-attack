#!/bin/sh
echo -ne '\033c\033]0;Dynamic Attack\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Dynamic Attack.x86_64" "$@"
