#!BuildTag: valkey:${VERSION}-%RELEASE%
#!BuildTag: valkey:${VERSION}
annotations:
  helm.sh/images: |
    - image: ${CONTAINER_REGISTRY}/containers/valkey:${APP_VERSION}
      name: valkey
    - image: ${CONTAINER_REGISTRY}/containers/redis-exporter:1
      name: redis-exporter
    - image: ${CONTAINER_REGISTRY}/containers/bci-busybox:15.5
      name: bci-busybox
apiVersion: v2
appVersion: ${APP_VERSION}
description: Valkey is a high-performance data structure server that primarily serves key/value workloads. It supports a wide range of native structures and an extensible plugin system for adding new data structures and access patterns.
home: https://apps.rancher.io/applications/valkey
maintainers:
  - name: SUSE LLC
    url: https://www.suse.com/
name: valkey
version: ${VERSION}
