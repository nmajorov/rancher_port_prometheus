global:
  # -- Global override for the storage class
  storageClassName: ""
  # -- Global override for container image registry
  imageRegistry: ""
  # -- Global override for container image registry pull secrets
  imagePullSecrets: []

# -- Annotations to add to all deployed objects
commonAnnotations: {}
# -- Labels to add to all deployed objects
commonLabels: {}
# -- Override the resource name
fullnameOverride: ""
# -- Override the resource name prefix (will keep the release name)
nameOverride: ""
# -- Additional Kubernetes manifests to include in the chart
extraManifests: []
# -- Kubernetes cluster domain name
clusterDomain: cluster.local

images:
  valkey:
    # -- Image registry to use for the Valkey container
    registry: ${CONTAINER_REGISTRY}
    # -- Image repository to use for the Valkey container
    repository: containers/valkey
    # -- Image tag to use for the Valkey container
    tag: ${APP_VERSION}
    # -- Image digest to use for the Valkey container (if set, `images.valkey.tag` will be ignored)
    digest: ""
    # -- Image pull policy to use for the Valkey container
    pullPolicy: IfNotPresent
  sentinel:
    # -- Image registry to use for the Valkey Sentinel container
    registry: ${CONTAINER_REGISTRY}
    # -- Image repository to use for the Valkey Sentinel container
    repository: containers/valkey
    # -- Image tag to use for the Valkey Sentinel container
    tag: ${APP_VERSION}
    # -- Image digest to use for the Valkey Sentinel container (if set, `images.sentinel.tag` will be ignored)
    digest: ""
    # -- Image pull policy to use for the Valkey Sentinel container
    pullPolicy: IfNotPresent
  metrics:
    # -- Image registry to use for the Redis Exporter container
    registry: ${CONTAINER_REGISTRY}
    # -- Image repository to use for the Redis Exporter container
    repository: containers/redis-exporter
    # -- Image tag to use for the Valkey container
    tag: "1"
    # -- Image digest to use for the Valkey container (if set, `images.valkey.tag` will be ignored)
    digest: ""
    # -- Image pull policy to use for the Valkey container
    pullPolicy: IfNotPresent
  volume-permissions:
    # -- Image registry to use for the volume permissions init container
    registry: ${CONTAINER_REGISTRY}
    # -- Image repository to use for the volume permissions init container
    repository: containers/bci-busybox
    # -- Image tag to use for the volume permissions init container
    tag: "15.5"
    # -- Image digest to use for the volume permissions init container (if set, `images.volume-permissions.tag` will be ignored)
    digest: ""
    # -- Image pull policy to use for the volume-permissions container
    pullPolicy: IfNotPresent

containerPorts:
  # -- (int32) Valkey port number for client connections
  valkey: 6379
  # -- (int32) Valkey Sentinel port number
  sentinel: 26379
  # -- (int32) Port number where metrics will be exposed to
  metrics: 9121
  # -- (int32) Custom port number to expose in the Valkey containers
  "*":
  # Note: This field is only added for documentation purposes

# -- Valkey architecture to deploy. Valid values: standalone, sentinel, cluster
architecture: standalone
auth:
  # -- Enable Valkey password authentication
  enabled: true
  # -- Valkey password
  password: ""
  # -- Name of a secret containing the Valkey password (if set, `auth.password` will be ignored)
  existingSecret: ""
  # -- Password key in the secret
  # @default `password`
  passwordKey: ""
tls:
  # -- Enable TLS
  enabled: false
  # -- Whether to require Valkey clients to authenticate with a valid certificate (authenticated against the trusted root CA certificate)
  authClients: true
  # -- Name of the secret containing the Valkey certificates
  existingSecret: ""
  # -- Certificate filename in the secret
  certFilename: ""
  # -- Certificate key filename in the secret
  keyFilename: ""
  # -- CA certificate filename in the secret
  caCertFilename: ""
  # -- Filename in the secret containing the DH params (for DH-based ciphers)
  dhParamsfilename: ""
  # -- Whether to use TLS for outgoing connections from replicas to the master
  replication: true
  # -- Whether to enable TLS for the cluster bus and cross-node connections (only for Valkey Cluster architecture)
  cluster: true
# -- List of Valkey commands to disable
disableCommands:
  - FLUSHALL
  - FLUSHDB
# -- Whether to enable Append Only File (AOF) mode
# See: https://github.com/valkey-io/valkey/blob/unstable/valkey.conf
appendOnlyFile: true
# -- Configuration file name in the config map
configurationFile: valkey.conf
# -- Extra configurations to add to the Valkey configuration file. Can be defined as a string, a key-value map, or an array of entries.
# See: https://github.com/valkey-io/valkey/blob/unstable/valkey.conf
configuration: ""
# -- Name of an existing config map for extra configurations to add to the Valkey configuration file
existingConfigMap: ""
# -- ConfigMaps to deploy
# @default -- See `values.yaml`
configMap:
  # -- Create a config map for Valkey configuration
  enabled: true
  # See: https://github.com/valkey-io/valkey/blob/unstable/valkey.conf
  '{{ .Values.configurationFile }}': '{{ tpl (include "configuration" (dict "header" (.Files.Get "config/valkey-defaults.conf.tpl") "context" $)) . }}'
  # -- (string) Custom configuration file to include, templates are allowed both in the config map name and contents
  "*":
  # Note: This field is only added for documentation purposes
# -- Secrets to deploy
# @default -- See `values.yaml`
secret:
  # -- Create a secret for Valkey credentials
  # @default -- `true` if authentication is enabled without existing secret, `false` otherwise
  enabled: '{{ and (eq (include "auth.enabled" .) "true") (not .Values.auth.existingSecret) }}'
  '{{ include "auth.passwordKey" . }}': '{{ default (randAlphaNum 16) .Values.auth.password }}'
  # -- (string) Custom secret to include, templates are allowed both in the secret name and contents
  "*":
  # Note: This field is only added for documentation purposes
# -- Desired number of Valkey nodes to deploy (counting the Valkey master node)
nodeCount: 1

statefulset:
  # -- Enable the StatefulSet template for Valkey standalone mode
  enabled: true
  # -- Override for the Valkey' StatefulSet serviceName field, it will be autogenerated if unset
  serviceName: ""
  # -- Template to use for all pods created by the Valkey StatefulSet (overrides `podTemplates.*`)
  template: {}
  # -- Desired number of PodTemplate replicas for Valkey (overrides `nodeCount`)
  replicas: ""
  # -- Strategy that will be employed to update the pods in the Valkey StatefulSet
  # @default -- See `values.yaml`
  updateStrategy:
    type: RollingUpdate
  # -- How Valkey pods are created during the initial scaleup
  podManagementPolicy: Parallel
  # -- Lifecycle of the persistent volume claims created from Valkey volumeClaimTemplates
  persistentVolumeClaimRetentionPolicy: {}
  #  whenScaled: Retain
  #  whenDeleted: Retain
  # -- Custom attributes for the Valkey StatefulSet (see [`StatefulSetSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/stateful-set-v1/#StatefulSetSpec))
  "*":
  # Note: This field is only added for documentation purposes

podTemplates:
  # -- Annotations to add to all pods in the Valkey StatefulSet's PodTemplate
  # @default -- See `values.yaml`
  annotations:
    kubectl.kubernetes.io/default-container: valkey
  # -- Labels to add to all pods in the Valkey StatefulSet's PodTemplate
  labels: {}
  # -- Init containers to deploy in the Valkey PodTemplate
  # @default -- See `values.yaml`
  # Each field has the init container name as key, and a YAML object template with the values; you must set `enabled: true` to enable it
  initContainers:
    volume-permissions:
      # -- Enable the volume-permissions init container in the Valkey PodTemplate
      enabled: false
      # -- Image override for the Valkey volume-permissions init container (if set, `images.volume-permissions.{name,tag,digest}` values will be ignored for this container)
      image: ""
      # -- Image pull policy override for the Valkey volume-permissions init container (if set `images.volume-permissions.pullPolicy` values will be ignored for this container)
      imagePullPolicy: ""
      # -- Entrypoint override for the Valkey volume-permissions container
      # @default -- See `values.yaml`
      command:
        - /bin/sh
        - -ec
        - |
          chown -R {{ .Values.containerSecurityContext.runAsUser }}:{{ .Values.podSecurityContext.fsGroup }} /mnt/valkey/data
      # -- Arguments override for the Valkey volume-permissions init container entrypoint
      args: []
      # -- Object with the environment variables templates to use in the Valkey volume-permissions init container, the values can be specified as an object or a string; when using objects you must also set `enabled: true` to enable it
      # @default -- No environment variables are set
      env: {}
      # -- List of sources from which to populate environment variables to the Valkey volume-permissions init container (e.g. a ConfigMaps or a Secret)
      envFrom: []
      # -- Custom volume mounts for the Valkey volume-permissions init container, templates are allowed in all fields
      # @default -- See `values.yaml`
      # Each field has the volume mount name as key, and a YAML string template with the values; you must set `enabled: true` to enable it
      volumeMounts:
        data:
          enabled: true
          mountPath: /mnt/valkey/data
      # -- Valkey init-containers resource requirements
      resources: {}
      # We usually recommend not to specify default resources and to leave this as a conscious
      # choice for the user. This also increases chances charts run on environments with little
      # resources, such as Minikube. If you do want to specify resources, uncomment the following
      # lines, adjust them as necessary, and remove the curly braces after 'resources:'
      #   limits:
      #    cpu: 100m
      #    memory: 128Mi
      #   requests:
      #    cpu: 100m
      #    memory: 128Mi
      # -- Security context override for the Valkey volume-permissions init container (if set, `containerSecurityContext.*` values will be ignored for this container)
      # @default -- See `values.yaml`
      securityContext:
        runAsUser: 0
      # -- Custom attributes for the Valkey volume-permissions init container (see [`Container` API spec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container))
      "*":
      # Note: This field is only added for documentation purposes
  # -- Containers to deploy in the Valkey PodTemplate
  # @default -- See `values.yaml`
  # Each field has the container name as key, and a YAML object template with the values; you must set `enabled: true` to enable it
  containers:
    valkey:
      # -- Enable the Valkey container in the PodTemplate
      enabled: true
      # -- Image override for the Valkey container (if set, `images.valkey.{name,tag,digest}` values will be ignored for this container)
      image: ""
      # -- Image pull policy override for the Valkey container (if set `images.valkey.pullPolicy` values will be ignored for this container)
      imagePullPolicy: ""
      # -- Entrypoint override for the Valkey container
      # @default -- See `values.yaml`
      command:
        - /bin/bash
        - -ec
        - |
          {{- if eq .Values.architecture "cluster" }}
          exec /mnt/valkey/scripts/valkey-cluster-entrypoint.sh
          {{- else }}
          exec /mnt/valkey/scripts/valkey-entrypoint.sh
          {{- end }}
      # -- Arguments override for the Valkey container entrypoint
      args: []
      # -- Ports override for the Valkey container (if set, `containerPorts.*` values will be ignored for this container)
      ports: {}
      # -- Object with the environment variables templates to use in the Valkey container, the values can be specified as an object or a string; when using objects you must also set `enabled: true` to enable it
      # @default -- See `values.yaml`
      env:
        REDISCLI_AUTH:
          enabled: '{{ eq (include "auth.enabled" .) "true" }}'
          value: '$(_VALKEY_PASSWORD)'
        # Environment variables used as placeholders or by initialization scripts
        _FQDN_CLUSTER_PREFIX: '{{ printf "%s.%s.svc.%s" (include "fullName" (dict "suffix" "headless" "context" $)) .Release.Namespace .Values.clusterDomain }}'
        _VALKEY_CONF_FILE: '{{ .Values.podTemplates.containers.valkey.volumeMounts.conf.mountPath }}/{{ .Values.configurationFile }}'
        _VALKEY_MASTER_HOST:
            enabled: '{{ ne .Values.architecture "cluster" }}'
            value: '{{ printf "%s.%s.%s.svc.%s" (include "fullName" (dict "suffix" "0" "context" $)) (include "fullName" (dict "suffix" "headless" "context" $)) .Release.Namespace .Values.clusterDomain }}'
        _VALKEY_PASSWORD:
          enabled: '{{ eq (include "auth.enabled" .) "true" }}'
          valueFrom:
            secretKeyRef:
              name: '{{ coalesce .Values.auth.existingSecret (include "fullName" .) }}'
              key: '{{ include "auth.passwordKey" . }}'
        _VALKEY_PORT: '{{ .Values.containerPorts.valkey }}'
        # Configurations specific to Valkey Cluster mode
        _VALKEY_CLUSTER_CONF_FILE:
            enabled: '{{ eq .Values.architecture "cluster" }}'
            value: '{{ .Values.podTemplates.containers.valkey.volumeMounts.data.mountPath }}/{{ .Values.cluster.configurationFile }}'
        _VALKEY_CLUSTER_NODES:
            enabled: '{{ eq .Values.architecture "cluster" }}'
            value: '{{ include "clusterNodes" . }}'
        _VALKEY_CLUSTER_REPLICAS_PER_MASTER:
            enabled: '{{ eq .Values.architecture "cluster" }}'
            value: '{{ .Values.cluster.replicasPerMaster }}'
      # -- List of sources from which to populate environment variables to the Valkey container (e.g. a ConfigMaps or a Secret)
      envFrom: []
      # -- Volume mount templates for the Valkey container, templates are allowed in all fields
      # @default -- See `values.yaml`
      # Each field has the volume mount name as key, and a YAML string template with the values; you must set `enabled: true` to enable it
      volumeMounts:
        conf:
          enabled: true
          mountPath: /mnt/valkey/conf
          readOnly: true
        data:
          enabled: true
          mountPath: /mnt/valkey/data
        scripts:
          enabled: true
          mountPath: /mnt/valkey/scripts
          readOnly: true
        certs:
          enabled: '{{ .Values.tls.enabled }}'
          mountPath: /mnt/valkey/certs
          readOnly: true
      # -- Custom resource requirements for the Valkey container
      resources: {}
      # We usually recommend not to specify default resources and to leave this as a conscious
      # choice for the user. This also increases chances charts run on environments with little
      # resources, such as Minikube. If you do want to specify resources, uncomment the following
      # lines, adjust them as necessary, and remove the curly braces after 'resources:'
      #   limits:
      #    cpu: 100m
      #    memory: 128Mi
      #   requests:
      #    cpu: 100m
      #    memory: 128Mi
      # -- Security context override for the Valkey container (if set, `containerSecurityContext.*` values will be ignored for this container)
      securityContext: {}
      livenessProbe:
        # -- Enable liveness probe for Valkey
        enabled: true
        # -- Command to execute for the Valkey startup probe
        # @default -- See `values.yaml`
        exec:
          command:
            - /mnt/valkey/scripts/valkey-liveness-check.sh
        # -- Number of seconds after the Valkey container has started before liveness probes are initiated
        initialDelaySeconds: 10
        # -- How often (in seconds) to perform the Valkey liveness probe
        periodSeconds: 10
        # -- Number of seconds after which the Valkey liveness probe times out
        timeoutSeconds: 5
        # -- Minimum consecutive failures for the Valkey liveness probe to be considered failed after having succeeded
        failureThreshold: 5
        # -- Minimum consecutive successes for the Valkey liveness probe to be considered successful after having failed
        successThreshold: 1
      readinessProbe:
        # -- Enable readiness probe for Valkey
        enabled: true
        # -- Command to execute for the Valkey startup probe
        # @default -- See `values.yaml`
        exec:
          command:
            - /mnt/valkey/scripts/valkey-readiness-check.sh
        # -- Number of seconds after the Valkey container has started before readiness probes are initiated
        initialDelaySeconds: 10
        # -- How often (in seconds) to perform the Valkey readiness probe
        periodSeconds: 10
        # -- Number of seconds after which the Valkey readiness probe times out
        timeoutSeconds: 5
        # -- Minimum consecutive failures for the Valkey readiness probe to be considered failed after having succeeded
        failureThreshold: 5
        # -- Minimum consecutive successes for the Valkey readiness probe to be considered successful after having failed
        successThreshold: 1
      startupProbe:
        # -- Enable startup probe for Valkey
        enabled: false
        # -- Port number used to check if the Valkey service is alive
        # @default -- See `values.yaml`
        tcpSocket:
          port: valkey
        # -- Number of seconds after the Valkey container has started before startup probes are initiated
        initialDelaySeconds: 0
        # -- How often (in seconds) to perform the Valkey startup probe
        periodSeconds: 10
        # -- Number of seconds after which the Valkey startup probe times out
        timeoutSeconds: 5
        # -- Minimum consecutive failures for the Valkey startup probe to be considered failed after having succeeded
        failureThreshold: 10
        # -- Minimum consecutive successes for the Valkey startup probe to be considered successful after having failed
        successThreshold: 1
      # -- Custom attributes for the Valkey container (see [`Container` API spec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container))
      "*":
      # Note: This field is only added for documentation purposes
    metrics:
      # -- Enable the redis-exporter container in the Valkey PodTemplate
      # @default -- Same value as `metrics.enabled`
      enabled: '{{ .Values.metrics.enabled }}'
      # -- Image override for the redis-exporter container (if set, `images.metrics.{name,tag,digest}` values will be ignored for this container)
      image: ""
      # -- Image pull policy override for the redis-exporter container (if set `images.metrics.pullPolicy` values will be ignored for this container)
      imagePullPolicy: ""
      # -- Entrypoint override for the redis-exporter container
      command: ""
      # -- Arguments override for the redis-exporter container entrypoint
      args: []
      # -- Ports override for the redis-exporter container (if set, `containerPorts.*` values will be ignored for this container)
      ports: {}
      # -- Object with the environment variables templates to use in the redis-exporter container, the values can be specified as an object or a string; when using objects you must also set `enabled: true` to enable it
      # @default -- See `values.yaml`
      env:
        REDIS_ADDR: '{{ printf "%s://localhost:%d" (ternary "rediss" "redis" .Values.tls.enabled) (int .Values.containerPorts.valkey) }}'
        REDIS_PASSWORD:
          enabled: '{{ eq (include "auth.enabled" .) "true" }}'
          valueFrom:
            secretKeyRef:
              name: '{{ coalesce .Values.auth.existingSecret (include "fullName" .) }}'
              key: '{{ include "auth.passwordKey" . }}'
        REDIS_EXPORTER_TLS_CLIENT_CERT_FILE:
          enabled: '{{ and .Values.tls.enabled .Values.tls.authClients }}'
          value: '{{ .Values.podTemplates.containers.metrics.volumeMounts.certs.mountPath }}/{{ .Values.tls.certFilename }}'
        REDIS_EXPORTER_TLS_CLIENT_KEY_FILE:
          enabled: '{{ and .Values.tls.enabled .Values.tls.authClients }}'
          value: '{{ .Values.podTemplates.containers.metrics.volumeMounts.certs.mountPath }}/{{ .Values.tls.keyFilename }}'
        REDIS_EXPORTER_TLS_CA_CERT_FILE:
          enabled: '{{ and .Values.tls.enabled .Values.tls.authClients }}'
          value: '{{ .Values.podTemplates.containers.metrics.volumeMounts.certs.mountPath }}/{{ .Values.tls.caCertFilename }}'
        REDIS_EXPORTER_WEB_LISTEN_ADDRESS: '{{ printf ":%d" (int .Values.containerPorts.metrics) }}'
      # -- List of sources from which to populate environment variables to the redis-exporter container (e.g. a ConfigMaps or a Secret)
      envFrom: []
      # -- Volume mount templates for the redis-exporter container, templates are allowed in all fields
      # @default -- See `values.yaml`
      # Each field has the volume mount name as key, and a YAML string template with the values; you must set `enabled: true` to enable it
      volumeMounts:
        certs:
          enabled: '{{ and .Values.tls.enabled .Values.tls.authClients }}'
          mountPath: /mnt/valkey/certs
          readOnly: true
      # -- Custom resource requirements for the redis-exporter container
      resources: {}
      # We usually recommend not to specify default resources and to leave this as a conscious
      # choice for the user. This also increases chances charts run on environments with little
      # resources, such as Minikube. If you do want to specify resources, uncomment the following
      # lines, adjust them as necessary, and remove the curly braces after 'resources:'
      #   limits:
      #    cpu: 100m
      #    memory: 128Mi
      #   requests:
      #    cpu: 100m
      #    memory: 128Mi
      # -- Security context override for the redis-exporter container (if set, `containerSecurityContext.*` values will be ignored for this container)
      securityContext: {}
      livenessProbe:
        # -- Enable liveness probe for redis-exporter
        enabled: true
        # -- Port number used to check if the redis-exporter service is alive
        # @default -- See `values.yaml`
        tcpSocket:
          port: metrics
        # -- Number of seconds after the redis-exporter container has started before liveness probes are initiated
        initialDelaySeconds: 10
        # -- How often (in seconds) to perform the redis-exporter liveness probe
        periodSeconds: 10
        # -- Number of seconds after which the redis-exporter liveness probe times out
        timeoutSeconds: 5
        # -- Minimum consecutive failures for the redis-exporter liveness probe to be considered failed after having succeeded
        failureThreshold: 5
        # -- Minimum consecutive successes for the redis-exporter liveness probe to be considered successful after having failed
        successThreshold: 1
      readinessProbe:
        # -- Enable readiness probe for redis-exporter
        enabled: true
        # -- HTTP endpoint used to check if the redis-exporter service is ready
        # @default -- See `values.yaml`
        httpGet:
          port: metrics
          path: /
        # -- Number of seconds after the redis-exporter container has started before readiness probes are initiated
        initialDelaySeconds: 10
        # -- How often (in seconds) to perform the redis-exporter readiness probe
        periodSeconds: 10
        # -- Number of seconds after which the redis-exporter readiness probe times out
        timeoutSeconds: 5
        # -- Minimum consecutive failures for the redis-exporter readiness probe to be considered failed after having succeeded
        failureThreshold: 5
        # -- Minimum consecutive successes for the redis-exporter readiness probe to be considered successful after having failed
        successThreshold: 1
      startupProbe:
        # -- Enable startup probe for redis-exporter
        enabled: false
        # -- Port number used to check if the redis-exporter service has been started
        # @default -- See `values.yaml`
        tcpSocket:
          port: metrics
        # -- Number of seconds after the redis-exporter container has started before startup probes are initiated
        initialDelaySeconds: 0
        # -- How often (in seconds) to perform the redis-exporter startup probe
        periodSeconds: 10
        # -- Number of seconds after which the redis-exporter startup probe times out
        timeoutSeconds: 5
        # -- Minimum consecutive failures for the redis-exporter startup probe to be considered failed after having succeeded
        failureThreshold: 10
        # -- Minimum consecutive successes for the redis-exporter startup probe to be considered successful after having failed
        successThreshold: 1
      # -- Custom attributes for the redis-exporter container (see [`Container` API spec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container))
      "*":
      # Note: This field is only added for documentation purposes
  # -- Custom pull secrets for the Valkey container in the PodTemplate
  imagePullSecrets: []
  # -- Volume templates for the Valkey PodTemplate, templates are allowed in all fields
  # @default -- See `values.yaml`
  # Each field has the volume name as key, and a YAML string template with the values; you must set `enabled: true` to enable it
  volumes:
    conf:
      enabled: true
      configMap:
        name: '{{ include "fullName" $ }}'
        defaultMode: 0o400
    data:
      enabled: '{{ and (not .Values.statefulset.volumeClaimTemplates) (not .Values.persistence.enabled) }}'
      emptyDir:
        medium: ""
    scripts:
      enabled: true
      configMap:
        name: '{{ include "fullName" (dict "suffix" "scripts" "context" $) }}'
        defaultMode: 0o550
    certs:
      enabled: '{{ .Values.tls.enabled }}'
      secret:
        secretName: '{{ tpl .Values.tls.existingSecret . }}'
        defaultMode: 0o400
  # -- Service account name override for the pods in the Valkey PodTemplate (if set, `serviceAccount.name` will be ignored)
  serviceAccountName: ""
  # -- Security context override for the pods in the Valkey PodTemplate (if set, `podSecurityContext.*` values will be ignored)
  securityContext: {}
  # -- Custom attributes for the pods in the Valkey PodTemplate (see [`PodSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodSpec))
  "*":
  # Note: This field is only added for documentation purposes

service:
  # -- Create a service for Valkey (apart from the headless service)
  enabled: true
  # -- Custom annotations to add to the service for Valkey
  annotations: {}
  # -- Valkey service type
  type: ClusterIP
  # Valkey service nodePort values
  nodePorts:
    # -- (int32) Service nodePort override for Valkey client connections
    valkey: ""
    # -- (int32) Service nodePort override for custom Valkey ports specified in `containerPorts.*`
    "*":
    # Note: This field is only added for documentation purposes
  # Service port values
  ports:
    # -- (int32) Service port override for Valkey client connections
    valkey: ""
    # -- (int32) Service port override for custom Valkey ports specified in `containerPorts.*`
    "*":
    # Note: This field is only added for documentation purposes
  # -- Custom attributes for the Valkey service (see [`ServiceSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/#ServiceSpec))
  "*":
  # Note: This field is only added for documentation purposes

headlessService:
  # -- Custom annotations to add to the headless service for Valkey
  annotations: {}
  # -- Valkey headless service type
  type: ClusterIP
  # IP address of the service
  # When clusterIP is "None", no virtual IP is allocated and the endpoints are published as a set of endpoints rather than a virtual IP
  clusterIP: None
  # -- Disregard indications of ready/not-ready
  # The primary use case for setting this field is for a StatefulSet's Headless Service to propagate SRV DNS records for its Pods for the purpose of peer discovery
  publishNotReadyAddresses: true
  # Headless service port values
  ports:
    # -- (int32) Headless service port override for Valkey client connections
    valkey: ""
    # -- (int32) Headless service port override for custom Valkey ports specified in `containerPorts.*`
    "*":
    # Note: This field is only added for documentation purposes
  # -- Custom attributes for the Valkey headless service (see [`ServiceSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/#ServiceSpec))
  "*":
  # Note: This field is only added for documentation purposes

# Valkey configurations for Sentinel (HA without partitioning)
sentinel:
  # -- Number of Sentinels to deploy (must be 3 or greater for cluster consistency in case of failover)
  nodeCount: 3
  # -- Name of the Valkey master set to monitor, which identifies a master and its replicas
  masterSet: mymaster
  # -- Number of Sentinels that must agree that a master is not reachable to start a failover proceedure.
  quorum: 2
  # -- Time in milliseconds an instance should not be reachable for a Sentinel starting to think it is down
  downAfterMilliseconds: 10000
  # -- Timeout for a Valkey failover to succeed
  failoverTimeout: 180000
  # -- Number of Valkey replicas that can be reconfigured to use the new master after a failover at the same time
  parallelSyncs: 1

  # -- Sentinel configuration file name in the config map
  configurationFile: sentinel.conf
  # -- Extra configurations to add to the Sentinel configuration file. Can be defined as a string, a key-value map, or an array of entries.
  # See: https://github.com/valkey-io/valkey/blob/unstable/sentinel.conf
  configuration: ""
  # -- Name of an existing config map for extra configurations to add to the Sentinel configuration file
  existingConfigMap: ""
  # -- ConfigMaps to deploy for Sentinel
  # @default -- See `values.yaml`
  configMap:
    # -- Create a config map for Sentinel configuration
    enabled: true
    # See: https://github.com/valkey-io/valkey/blob/unstable/sentinel.conf
    '{{ .Values.sentinel.configurationFile }}': '{{ tpl (include "configuration" (dict "header" (.Files.Get "config/sentinel-defaults.conf.tpl") "values" .Values.sentinel.configuration "context" $)) . }}'
    # -- (string) Custom Sentinel configuration file to include, templates are allowed both in the config map name and contents
    "*":
    # Note: This field is only added for documentation purposes

  statefulset:
    # -- Enable the StatefulSet template for Sentinel
    enabled: true
    # -- Override for Sentinel's StatefulSet serviceName field, it will be autogenerated if unset
    serviceName: ""
    # -- Template to use for all pods created by the Sentinel StatefulSet (overrides `podTemplates.*`)
    template: {}
    # -- Desired number of PodTemplate replicas for Sentinel (overrides `sentinel.nodeCount`)
    replicas: ""
    # -- Strategy that will be employed to update the pods in the Sentinel StatefulSet
    # @default -- See `values.yaml`
    updateStrategy:
      type: RollingUpdate
    # -- How Sentinel pods are created during the initial scaleup
    podManagementPolicy: Parallel
    # -- Lifecycle of the persistent volume claims created from Sentinel volumeClaimTemplates
    persistentVolumeClaimRetentionPolicy: {}
    #  whenScaled: Retain
    #  whenDeleted: Retain
    # -- Custom attributes for the Sentinel StatefulSet (see [`StatefulSetSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/stateful-set-v1/#StatefulSetSpec))
    "*":
    # Note: This field is only added for documentation purposes

  podTemplates:
    # -- Annotations to add to all pods in Sentinel's StatefulSet PodTemplate
    # @default -- See `values.yaml`
    annotations:
      kubectl.kubernetes.io/default-container: sentinel
    # -- Labels to add to all pods in Sentinel's StatefulSet PodTemplate
    labels: {}
    # -- Init containers to deploy in the Sentinel PodTemplate
    # @default -- See `values.yaml`
    # Each field has the init container name as key, and a YAML object template with the values; you must set `enabled: true` to enable it
    initContainers:
      volume-permissions:
        # -- Enable the volume-permissions init container in the Sentinel PodTemplate
        enabled: false
        # -- Image override for the Sentinel volume-permissions init container (if set, `images.volume-permissions.{name,tag,digest}` values will be ignored for this container)
        image: ""
        # -- Image pull policy override for the Sentinel volume-permissions init container (if set `images.volume-permissions.pullPolicy` values will be ignored for this container)
        imagePullPolicy: ""
        # -- Entrypoint override for the Sentinel volume-permissions container
        # @default -- See `values.yaml`
        command:
          - /bin/sh
          - -ec
          - |
            chown -R {{ .Values.containerSecurityContext.runAsUser }}:{{ .Values.podSecurityContext.fsGroup }} /mnt/sentinel
        # -- Arguments override for the Sentinel volume-permissions init container entrypoint
        args: []
        # -- Object with the environment variables templates to use in the Sentinel volume-permissions init container, the values can be specified as an object or a string; when using objects you must also set `enabled: true` to enable it
        # @default -- No environment variables are set
        env: {}
        # -- List of sources from which to populate environment variables to the Sentinel volume-permissions init container (e.g. a ConfigMaps or a Secret)
        envFrom: []
        # -- Custom volume mounts for the Sentinel volume-permissions init container, templates are allowed in all fields
        # @default -- See `values.yaml`
        # Each field has the volume mount name as key, and a YAML string template with the values; you must set `enabled: true` to enable it
        volumeMounts:
          data:
            enabled: true
            mountPath: /mnt/sentinel/data
        # -- Sentinel init-containers resource requirements
        resources: {}
        # We usually recommend not to specify default resources and to leave this as a conscious
        # choice for the user. This also increases chances charts run on environments with little
        # resources, such as Minikube. If you do want to specify resources, uncomment the following
        # lines, adjust them as necessary, and remove the curly braces after 'resources:'
        #   limits:
        #    cpu: 100m
        #    memory: 128Mi
        #   requests:
        #    cpu: 100m
        #    memory: 128Mi
        # -- Security context override for the Sentinel volume-permissions init container (if set, `containerSecurityContext.*` values will be ignored for this container)
        # @default -- See `values.yaml`
        securityContext:
          runAsUser: 0
        # -- Custom attributes for the Sentinel volume-permissions init container (see [`Container` API spec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container))
        "*":
        # Note: This field is only added for documentation purposes
    # -- Sentinel containers to deploy in the PodTemplate
    # @default -- See `values.yaml`
    # Each field has the container name as key, and a YAML object template with the values; you must set `enabled: true` to enable it
    containers:
      sentinel:
        # -- Enable the Sentinel container in the PodTemplate
        enabled: true
        # -- Image for the Sentinel container
        image: ""
        # -- Image pull policy override for the Sentinel container
        imagePullPolicy: ""
        # -- Entrypoint override for the Sentinel container
        # @default -- See `values.yaml`
        command:
          - /mnt/sentinel/scripts/sentinel-entrypoint.sh
        # -- Arguments override for the Sentinel container entrypoint
        args: []
        # -- Ports override for the Sentinel container (if set, `containerPorts.*` values will be ignored for this container)
        ports: {}
        # -- Object with the environment variables templates to use in the Sentinel container, the values can be specified as an object or a string; when using objects you must also set `enabled: true` to enable it
        # @default -- See `values.yaml`
        env:
          # Environment variables used as placeholders or by initialization scripts
          _VALKEY_MASTER_HOST: '{{ printf "%s.%s.%s.svc.%s" (include "fullName" (dict "suffix" "0" "context" $)) (include "fullName" (dict "suffix" "headless" "context" $)) .Release.Namespace .Values.clusterDomain }}'
          _VALKEY_PASSWORD:
            enabled: '{{ eq (include "auth.enabled" .) "true" }}'
            valueFrom:
              secretKeyRef:
                name: '{{ coalesce .Values.auth.existingSecret (include "fullName" .) }}'
                key: '{{ include "auth.passwordKey" . }}'
          _VALKEY_PORT: '{{ .Values.containerPorts.valkey }}'
          _SENTINEL_DEFAULTS_CONF_FILE: '{{ .Values.sentinel.podTemplates.containers.sentinel.volumeMounts.conf.mountPath }}/{{ .Values.sentinel.configurationFile }}'
          _SENTINEL_CONF_FILE: '{{ .Values.sentinel.podTemplates.containers.sentinel.volumeMounts.data.mountPath }}/{{ .Values.sentinel.configurationFile }}'
          _SENTINEL_DOWN_AFTER_MS: '{{ .Values.sentinel.downAfterMilliseconds }}'
          _SENTINEL_FAILOVER_TIMEOUT: '{{ .Values.sentinel.failoverTimeout }}'
          _SENTINEL_MASTER_SET: '{{ .Values.sentinel.masterSet }}'
          _SENTINEL_PORT: '{{ .Values.containerPorts.sentinel }}'
          _SENTINEL_PARALLEL_SYNCS: '{{ .Values.sentinel.parallelSyncs }}'
          _SENTINEL_QUORUM: '{{ .Values.sentinel.quorum }}'
        # -- List of sources from which to populate environment variables to the Sentinel container (e.g. a ConfigMaps or a Secret)
        envFrom: []
        # -- Volume mount templates for the Sentinel container, templates are allowed in all fields
        # @default -- See `values.yaml`
        # Each field has the volume mount name as key, and a YAML string template with the values; you must set `enabled: true` to enable it
        volumeMounts:
          conf:
            enabled: true
            mountPath: /mnt/sentinel/conf-defaults
            readOnly: true
          data:
            enabled: true
            mountPath: /mnt/sentinel/data
          scripts:
            enabled: true
            mountPath: /mnt/sentinel/scripts
            readOnly: true
          certs:
            enabled: '{{ .Values.tls.enabled }}'
            mountPath: /mnt/sentinel/certs
            readOnly: true
        # -- Custom resource requirements for the Sentinel container
        resources: {}
        # We usually recommend not to specify default resources and to leave this as a conscious
        # choice for the user. This also increases chances charts run on environments with little
        # resources, such as Minikube. If you do want to specify resources, uncomment the following
        # lines, adjust them as necessary, and remove the curly braces after 'resources:'
        #   limits:
        #    cpu: 100m
        #    memory: 128Mi
        #   requests:
        #    cpu: 100m
        #    memory: 128Mi
        # -- Security context override for the Sentinel container (if set, `containerSecurityContext.*` values will be ignored for this container)
        securityContext: {}
        livenessProbe:
          # -- Enable liveness probe for Sentinel
          enabled: true
          # -- Command to execute for the Sentinel startup probe
          # @default -- See `values.yaml`
          exec:
            command:
              - /mnt/sentinel/scripts/sentinel-healthcheck.sh
          # -- Number of seconds after the Sentinel container has started before liveness probes are initiated
          initialDelaySeconds: 10
          # -- How often (in seconds) to perform the Sentinel liveness probe
          periodSeconds: 10
          # -- Number of seconds after which the Sentinel liveness probe times out
          timeoutSeconds: 5
          # -- Minimum consecutive failures for the Sentinel liveness probe to be considered failed after having succeeded
          failureThreshold: 5
          # -- Minimum consecutive successes for the Sentinel liveness probe to be considered successful after having failed
          successThreshold: 1
        readinessProbe:
          # -- Enable readiness probe for Sentinel
          enabled: true
          # -- Command to execute for the Sentinel startup probe
          # @default -- See `values.yaml`
          exec:
            command:
              - /mnt/sentinel/scripts/sentinel-healthcheck.sh
          # -- Number of seconds after the Sentinel container has started before readiness probes are initiated
          initialDelaySeconds: 10
          # -- How often (in seconds) to perform the Sentinel readiness probe
          periodSeconds: 10
          # -- Number of seconds after which the Sentinel readiness probe times out
          timeoutSeconds: 5
          # -- Minimum consecutive failures for the Sentinel readiness probe to be considered failed after having succeeded
          failureThreshold: 5
          # -- Minimum consecutive successes for the Sentinel readiness probe to be considered successful after having failed
          successThreshold: 1
        startupProbe:
          # -- Enable startup probe for Sentinel
          enabled: false
          # -- Command to execute for the Sentinel startup probe
          # @default -- See `values.yaml`
          exec:
            command:
              - /mnt/sentinel/scripts/sentinel-healthcheck.sh
          # -- Number of seconds after the container has started before startup probes are initiated
          initialDelaySeconds: 0
          # -- How often (in seconds) to perform the Sentinel startup probe
          periodSeconds: 10
          # -- Number of seconds after which the Sentinel startup probe times out
          timeoutSeconds: 5
          # -- Minimum consecutive failures for the Sentinel startup probe to be considered failed after having succeeded
          failureThreshold: 10
          # -- Minimum consecutive successes for the Sentinel startup probe to be considered successful after having failed
          successThreshold: 1
        # -- Custom attributes for the Sentinel container (see [`Container` API spec](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#Container))
        "*":
        # Note: This field is only added for documentation purposes
    # -- Custom pull secrets for the Sentinel container in the PodTemplate
    imagePullSecrets: []
    # -- Volume templates for the Sentinel PodTemplate, templates are allowed in all fields
    # @default -- See `values.yaml`
    # Each field has the volume name as key, and a YAML string template with the values; you must set `enabled: true` to enable it
    volumes:
      conf:
        enabled: true
        configMap:
          name: '{{ include "fullName" (dict "suffix" "sentinel" "context" $) }}'
          defaultMode: 0o400
      data:
        enabled: '{{ and (not .Values.sentinel.statefulset.volumeClaimTemplates) (not .Values.persistence.enabled) }}'
        emptyDir:
          medium: ""
      scripts:
        enabled: true
        configMap:
          name: '{{ include "fullName" (dict "suffix" "sentinel-scripts" "context" $) }}'
          defaultMode: 0o550
      certs:
        enabled: '{{ .Values.tls.enabled }}'
        secret:
          secretName: '{{ tpl .Values.tls.existingSecret . }}'
          defaultMode: 0o400
    # -- Service account name override for the pods in the Sentinel PodTemplate (if set, `serviceAccount.name` will be ignored)
    serviceAccountName: ""
    # -- Security context override for the pods in the Sentinel PodTemplate (if set, `podSecurityContext.*` values will be ignored)
    securityContext: {}
    # -- Custom attributes for the pods in the Sentinel PodTemplate (see [`PodSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/#PodSpec))
    "*":
    # Note: This field is only added for documentation purposes

  service:
    # -- Create a service for Sentinel (apart from the headless service)
    enabled: true
    # -- Custom annotations to add to the service for Sentinel
    annotations: {}
    # -- Sentinel service type
    type: ClusterIP
    # Service nodePort values
    nodePorts:
      # -- (int32) Service nodePort override for Sentinel connections
      sentinel: ""
      # -- (int32) Service nodePort override for custom Sentinel ports specified in `containerPorts.*`
      "*":
      # Note: This field is only added for documentation purposes
    # Service port values
    ports:
      # -- (int32) Service port override for Sentinel connections
      sentinel: ""
      # -- (int32) Service port override for custom Sentinel ports specified in `containerPorts.*`
      "*":
      # Note: This field is only added for documentation purposes
    # -- Custom attributes for the Sentinel service (see [`ServiceSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/#ServiceSpec))
    "*":
    # Note: This field is only added for documentation purposes

# Valkey Cluster configurations (HA with partitioning)
cluster:
  # -- Amount of replicas per master node that will be configured in the cluster. It must satisfy this rule: `nodeCount = masterCount + (masterCount * replicasPerMaster)`.
  # Or alternatively: `replicasPerMaster = (nodeCount - masterCount) / masterCount`. And all valuest must be whole numbers.
  # For example, for 6 nodes, if you want 3 masters, then the nodeCount value (number of replicas per master) must be set to 1.
  replicasPerMaster: 0
  # -- Valkey Cluster configuration file name in the volume
  configurationFile: nodes.conf

metrics:
  # -- Expose Valkey metrics
  enabled: false
  # -- Annotations to add to all pods that expose metrics
  # @default -- See `values.yaml`
  annotations:
    prometheus.io/scrape: "true"
    prometheus.io/port: '{{ coalesce .Values.containerPorts.metrics .Values.containerPorts.client }}'
  prometheusRule:
    # -- Content of the Prometheus rule file
    # See https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/
    configuration: {}
    # Example Prometheus rule file copied from https://github.com/bdossantos/prometheus-alert-rules/blob/master/rules/redis.yml:
    # - alert: ValkeyDown
    #   expr: redis_up == 0
    #   for: 5m
    #   labels:
    #     severity: critical
    #   annotations:
    #     summary: Valkey down (instance {{ $labels.instance }})
    #     description: "Valkey instance is down\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"
    # -- Create a PrometheusRule resource (also requires `metrics.enabled` to be enabled)
    enabled: false
    # -- Additional labels that will be added to the PrometheusRule resource
    labels: {}
    # -- Namespace for the PrometheusRule resource (defaults to the release namespace)
    namespace: ""
  service:
    # -- Create a service for redis-exporter (apart from the headless service)
    enabled: true
    # -- Custom annotations to add to the service for redis-exporter
    annotations: {}
    # -- Service type
    type: ClusterIP
    # Service nodePort values
    nodePorts:
      # -- (int32) Service nodePort override for redis-exporter metrics connections
      metrics: ""
      # -- (int32) Service nodePort override for custom ports specified in `containerPorts.*`
      "*":
      # Note: This field is only added for documentation purposes
    # Service port values
    ports:
      # -- (int32) Service port override for redis-exporter metrics connections
      metrics: ""
      # -- (int32) Service port override for custom ports specified in `containerPorts.*`
      "*":
      # Note: This field is only added for documentation purposes
    # -- Custom attributes for the service (see [`ServiceSpec` API reference](https://kubernetes.io/docs/reference/kubernetes-api/service-resources/service-v1/#ServiceSpec))
    "*":
    # Note: This field is only added for documentation purposes

persistence:
  # -- Enable persistent volume claims for Valkey pods
  enabled: true
  # -- Custom annotations to add to the persistent volume claims used by Valkey pods
  annotations: {}
  # -- Custom labels to add to the persistent volume claims used by Valkey pods
  labels: {}
  # -- Name of an existing PersistentVolumeClaim to use by Valkey pods
  existingClaim: ""
  # -- Persistent volume access modes
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      # -- Size of the persistent volume claim to create for Valkey pods
      storage: 8Gi
  # -- Storage class name to use for the Valkey persistent volume claim
  storageClassName: ""

podSecurityContext:
  # -- Enable pod security context
  enabled: true
  # -- Group ID that will write to persistent volumes
  fsGroup: 1000

containerSecurityContext:
  # -- Enable container security context
  enabled: true
  # -- Allow privilege escalation within containers
  allowPrivilegeEscalation: false
  # -- Run containers as a non-root user
  runAsNonRoot: true
  # -- Which user ID to run the container as
  runAsUser: 1000

networkPolicy:
  # -- Create a NetworkPolicy resource
  enabled: false
  # -- Allow all external connections from and to the pods
  allowExternalConnections: true
  egress:
    # -- Create an egress network policy (requires also `networkPolicy.enabled`)
    enabled: true
    # -- Allow all external egress connections from the pods (requires also `networkPolicy.allowExternalConnections`)
    allowExternalConnections: true
    # -- Custom additional egress rules to enable in the NetworkPolicy resource
    extraRules: []
    # -- List of namespace labels for which to allow egress connections, when external connections are disallowed
    namespaceLabels: {}
    # -- List of pod labels for which to allow egress connections, when external connections are disallowed
    podLabels: {}
    # Network policy port overrides for egress connections
    ports:
      # -- (int32) Network policy port override for Valkey client connections for egress connections
      client: ""
      # -- (int32) Network policy port override for Valkey peer connections for egress connections
      peer: ""
      # -- (int32) Network policy port override for custom ports specified in `containerPorts.*` for egress connections
      "*":
      # Note: This field is only added for documentation purposes
  ingress:
    # -- Create an ingress network policy (requires also `networkPolicy.enabled`)
    enabled: true
    # -- Allow all external ingress connections to the pods (requires also `networkPolicy.allowExternalConnections`)
    allowExternalConnections: true
    # -- List of namespace labels for which to allow ingress connections, when external connections are disallowed
    namespaceLabels: {}
    # -- List of pod labels for which to allow ingress connections, when external connections are disallowed
    podLabels: {}
    # -- Custom additional ingress rules to enable in the NetworkPolicy resource
    extraRules: []
    # Network policy port overrides for ingress connections
    ports:
      # -- (int32) Network policy port override for Valkey client connections for ingress connections
      client: ""
      # -- (int32) Network policy port override for Valkey peer connections for ingress connections
      peer: ""
      # -- (int32) Network policy port override for custom ports specified in `containerPorts.*` for ingress connections
      "*":
      # Note: This field is only added for documentation purposes

podDisruptionBudget:
  # -- Create a pod disruption budget
  enabled: false
  # -- Number of pods from that set that must still be available after the eviction, this option is mutually exclusive with maxUnavailable
  minAvailable: ""
  # -- Number of pods from that can be unavailable after the eviction, this option is mutually exclusive with minAvailable
  maxUnavailable: ""

serviceAccount:
  # -- Create or use an existing service account
  enabled: false
  # -- Add custom annotations to the ServiceAccount
  annotations: {}
  # -- Add custom labels to the ServiceAccount
  labels: {}
  # -- Name of the ServiceAccount to use
  name: ""
  # -- Whether pods running as this service account should have an API token automatically mounted
  automountServiceAccountToken: true
  # -- List of references to secrets in the same namespace to use for pulling any images in pods that reference this ServiceAccount
  imagePullSecrets: []
  # -- List of secrets in the same namespace that pods running using this ServiceAccount are allowed to use
  secrets: []
