# Deployment Configuration (GitOps)

This repository contains declarative Kubernetes manifests synchronized by Flux CD.

## CI/CD Handoff Contract
* **Target File:** `apps/python-flaskapp/deployment.yaml`
* **JSONPath:** `spec.template.spec.containers[0].image`
* **Managed By:** Jenkins CI Bot
* **Format:** `<dockerhub-username>/python-flaskapp:v<BUILD_NUMBER>-<SHORT_SHA>`

Flux polls this repository every 30 seconds and reconciles `./apps/python-flaskapp` into the `flask-app` namespace.
