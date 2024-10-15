bind 0.0.0.0 ::
{{- if not .Values.tls.enabled }}
port {{ printf "%d" (int .Values.containerPorts.valkey) }}
{{- else }}
port 0
{{- end }}
dir {{ .Values.podTemplates.containers.valkey.volumeMounts.data.mountPath }}
appendonly {{ ternary "yes" "no" .Values.appendOnlyFile }}

{{- if .Values.disableCommands }}
# Disable Valkey commands for security purposes
{{- range .Values.disableCommands }}
rename-command {{ . }} ""
{{- end }}
{{- end }}

{{- if .Values.tls.enabled }}
# TLS configuration
tls-port {{ printf "%d" (int .Values.containerPorts.valkey) }}
tls-cert-file {{ .Values.podTemplates.containers.valkey.volumeMounts.certs.mountPath }}/{{ .Values.tls.certFilename }}
tls-key-file {{ .Values.podTemplates.containers.valkey.volumeMounts.certs.mountPath }}/{{ .Values.tls.keyFilename }}
tls-ca-cert-file {{ .Values.podTemplates.containers.valkey.volumeMounts.certs.mountPath }}/{{ .Values.tls.caCertFilename }}
tls-auth-clients {{ ternary "yes" "no" .Values.tls.authClients }}
tls-replication {{ ternary "yes" "no" .Values.tls.replication }}
{{- if .Values.tls.dhParamsFilename }}
tls-dh-params-file {{ .Values.podTemplates.containers.valkey.volumeMounts.certs.mountPath }}/{{ .Values.tls.dhParamsFilename }}
{{- end }}
{{- end }}

{{- if eq .Values.architecture "cluster" }}
# Cluster configuration
cluster-enabled yes
cluster-config-file {{ .Values.cluster.configurationFile }}
cluster-preferred-endpoint-type hostname
{{- if .Values.tls.enabled }}
tls-cluster {{ ternary "yes" "no" .Values.tls.cluster }}
{{- end }}
{{- end }}
