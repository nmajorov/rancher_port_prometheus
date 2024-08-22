{{/*
    Print true if authentication is enabled, false otherwise.
*/}}
{{- define "auth.enabled" }}
    {{- .Values.auth.enabled }}
{{- end }}

{{/*
    Print the existing secret name for authentication configuration. Supports the following non-standard values:
    - auth.existingSecretPasswordKey
*/}}
{{- define "auth.passwordKey" }}
    {{- coalesce .Values.auth.passwordKey .Values.auth.existingSecretPasswordKey "password" }}
{{- end }}

{{- define "configuration" }}
    {{- $context := default . .context }}
    {{- $configuration := default $context.Values.configuration .values }}
    {{- $configurationHeader := default "" .header }}
    {{- $configurationHeader }}
    {{- $configurationEntries := list }}
    {{- if $configuration }}
        {{- if kindIs "string" $configuration }}
            {{- $configurationEntries = append $configurationEntries (tpl $configuration $) }}
        {{- else if kindIs "array" $configuration }}
            {{- $configurationEntries = concat $configurationEntries (tpl $configuration $) }}
        {{- else }}
            {{- range $configKey, $configValue := $configuration }}
                {{- if not (kindIs "string" $configValue) }}
                    {{- if eq (include "templateToBoolean" (dict "template" $configValue.enabled "context" $context)) "true" }}
                        {{- $configurationEntries = append $configurationEntries (printf "%s %s" (tpl $configKey $context) (tpl $configValue.value $context)) }}
                    {{- end }}
                {{- else }}
                    {{- $configurationEntries = append $configurationEntries (printf "%s %s" (tpl $configKey $context) (tpl $configValue $context)) }}
                {{- end }}
            {{- end }}
        {{- end }}
        {{- if $configurationEntries }}
            {{- $configurationEntries = prepend $configurationEntries "# Custom configurations" }}
            {{- join "\n" $configurationEntries | nindent 0 }}
        {{- end }}
    {{- end }}
{{- end }}

{{/*
    Valkey Cluster nodes.
*/}}
{{- define "clusterNodes" }}
    {{- $clusterNodes := list }}
    {{- $fullName := include "fullName" . }}
    {{- $serviceName := coalesce .Values.statefulset.serviceName (include "fullName" (dict "suffix" "headless" "context" .)) }}
    {{- $releaseNamespace := .Release.Namespace }}
    {{- $clusterDomain := .Values.clusterDomain }}
    {{- $port := int (coalesce .Values.headlessService.ports.valkey .Values.containerPorts.valkey) }}
    {{- range $node := (until (int .Values.statefulset.replicas)) }}
        {{- $clusterNodes = append $clusterNodes (printf "%s-%d.%s.%s.svc.%s:%d" $fullName $node $serviceName $releaseNamespace $clusterDomain $port) }}
    {{- end }}
    {{- join "," $clusterNodes }}
{{- end }}
