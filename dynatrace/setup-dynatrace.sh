#!/bin/bash
# Installs the Dynatrace Operator (via Helm) and deploys a DynaKube CR into the
# "dynatrace" namespace, wired up with this environment's tenant URL, tokens,
# and cluster/network-zone name.
# Run this AFTER your Kubernetes cluster exists (e.g. after `kind create cluster`).
#
# Requires DT_URL, DT_TOKEN, and DT_OPERATOR_TOKEN to be set in the environment
# (populated automatically from devcontainer.json "secrets" in Codespaces/Dev Containers).
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DYNAKUBE_FILE="$SCRIPT_DIR/dynakube.yaml"

if [[ -z "$DT_URL" || -z "$DT_TOKEN" || -z "$DT_OPERATOR_TOKEN" ]]; then
  echo "❌ DT_URL, DT_TOKEN, and/or DT_OPERATOR_TOKEN are not set in the environment." >&2
  echo "   These come from the devcontainer secrets — rebuild the container or export them manually." >&2
  exit 1
fi

# GITHUB_USER is set automatically in GitHub Codespaces; fall back for local Dev Containers.
CLUSTER_NAME="${GITHUB_USER:-$(whoami)}"

# Bare hostname (no scheme, no trailing slash) — needed for the registry repository field,
# which can't take a full https:// URL like DT_URL/apiUrl can.
DT_HOST="${DT_URL#*://}"
DT_HOST="${DT_HOST%/}"

# 1. Install the Dynatrace Operator via Helm.
#    --create-namespace creates "dynatrace" (no separate `kubectl create namespace` needed).
#    --atomic waits for the release to become ready and rolls back on failure, so no
#    manual sleep/wait is needed after this step. `upgrade --install` keeps this idempotent.
helm upgrade --install dynatrace-operator oci://public.ecr.aws/dynatrace/dynatrace-operator \
  --create-namespace \
  --namespace dynatrace \
  --atomic

# 2. Create the tokens secret.
#    --dry-run=client -o yaml | kubectl apply -f - keeps this idempotent on re-run.
kubectl -n dynatrace create secret generic dynakube \
  --from-literal="apiToken=$DT_OPERATOR_TOKEN" \
  --from-literal="dataIngestToken=$DT_TOKEN" \
  --dry-run=client -o yaml | kubectl apply -f -

# 3. Patch dynakube.yaml with this environment's tenant URL, tenant host, and cluster identifier.
#    Safe to re-run: once replaced, the placeholder text no longer matches, so sed is a no-op.
sed -i "s,TENANTURL_TOREPLACE,$DT_URL,g" "$DYNAKUBE_FILE"
sed -i "s,TENANTHOST_TOREPLACE,$DT_HOST,g" "$DYNAKUBE_FILE"
sed -i "s,CLUSTER_NAME_TO_REPLACE,$CLUSTER_NAME,g" "$DYNAKUBE_FILE"

# 4. Apply the DynaKube custom resources (OneAgent, ActiveGate, etc.).
kubectl -n dynatrace apply -f "$DYNAKUBE_FILE"

echo "✅ Dynatrace Operator installed, secret created, and DynaKube applied."
echo "   Tenant: $DT_URL | Cluster/network zone: $CLUSTER_NAME"
