#!/usr/bin/env bash

# Get the pod
NAMESPACE="${NAMESPACE:-rails-backend-production}"
POD_PREFIX="${POD_PREFIX:-sidekiq}"

kubectl \
  --namespace "${NAMESPACE}" \
  get pods \
  --output name |
  grep "^pod/${POD_PREFIX}" |
  xargs kubectl \
    --namespace "${NAMESPACE}" \
    get --output wide
