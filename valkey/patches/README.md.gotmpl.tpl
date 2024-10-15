# Valkey Helm Chart

> [Valkey](https://valkey.io) is an open source, in-memory data structure store, used as a database, cache, and message broker.

## Introduction

This Helm chart bootstraps an [Valkey](https://valkey.io) deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Quick Start

```console
helm install my-release ${CHART_REGISTRY}/valkey
```

### Prerequisites

* Helm 3.8.0 or later.
* Kubernetes 1.24 or later.
* PV provisioner support in the underlying infrastructure.

## Install Chart

To install the Helm chart with the release name *my-release*:

```console
helm install my-release \
    --set 'global.imagePullSecrets[0].name'=my-pull-secrets \
    ${CHART_REGISTRY}/valkey \
```

This deploys the application to the Kubernetes cluster using the default configuration provided by the Helm chart.

> NOTE: You can follow [these steps](https://cloud.google.com/artifact-registry/docs/access-control#pullsecrets)
> to create and setup the image pull secrets, if you don't have them already.

## Uninstall Chart

To uninstall the Helm chart with the release name *my-release*:

```console
helm uninstall my-release
```

This removes all the Kubernetes components associated to the Helm chart

{{ template "chart.valuesSection" . }}

### Override Values

To override a parameter, add *--set* flags to the *helm install* command. For example:

```console
helm install my-release --set images.valkey.tag=${APP_VERSION} ${CHART_REGISTRY}/valkey
```

Alternatively, you can override the parameter values using a custom YAML file with the *-f* flag. For example:

```console
helm install my-release -f custom-values.yaml ${CHART_REGISTRY}/valkey
```

Read more about [Values files](https://helm.sh/docs/chart_template_guide/values_files/) in the [Helm documentation](https://helm.sh/docs/).

## Missing Features

The following features are acknowledged missing from this Helm chart, and are expected to be added in a future revision:

* Snapshot creation of backup data.
* Disaster recovery of the backup data, in case of a majority failure due to lack of quorum.
