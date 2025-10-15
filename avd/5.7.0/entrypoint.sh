#!/bin/bash

set -euo pipefail

umask 002

source ${AVD_VENV}/bin/activate

exec "$@"
