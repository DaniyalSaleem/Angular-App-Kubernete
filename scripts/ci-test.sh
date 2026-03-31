#!/usr/bin/env bash
# Run Angular unit tests in headless Chrome (suitable for CI environments).
# Outputs:
#   coverage/cobertura-coverage.xml  – Cobertura report (for Azure Pipelines)
#   coverage/lcov.info               – LCOV report
#   coverage/html/                   – HTML report (published as artifact)
set -euo pipefail

npx ng test \
  --watch=false \
  --browsers=ChromeHeadlessNoSandbox
