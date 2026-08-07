{{/*
Expand the name of the chart.
*/}}
{{- define "devsecops-platform.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "devsecops-platform.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name (include "devsecops-platform.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}