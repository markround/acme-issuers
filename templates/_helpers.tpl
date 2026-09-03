{{/*
Expand the name of the chart.
*/}}
{{- define "acme-issuers.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "acme-issuers.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "acme-issuers.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "acme-issuers.labels" -}}
helm.sh/chart: {{ include "acme-issuers.chart" . }}
{{ include "acme-issuers.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "acme-issuers.selectorLabels" -}}
app.kubernetes.io/name: {{ include "acme-issuers.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Render the ACME solvers for a single issuer, in cert-manager's
`spec.acme.solvers` format. Precedence, highest first:

  1. the issuer's own `solvers` list
  2. the global `.Values.solvers` list
  3. a built-in HTTP-01 ingress solver using `.Values.ingressClass`

Usage: include "acme-issuers.solvers" (dict "issuer" . "root" $)
*/}}
{{- define "acme-issuers.solvers" -}}
{{- $issuer := .issuer -}}
{{- $root := .root -}}
{{- $solvers := $issuer.solvers | default $root.Values.solvers -}}
{{- if $solvers -}}
{{- toYaml $solvers }}
{{- else if $root.Values.ingressClass -}}
- http01:
    ingress:
      class: {{ $root.Values.ingressClass }}
{{- else -}}
{{- fail (printf "clusterIssuer %q has no solver: set ingressClass, solvers, or a per-issuer solvers list" $issuer.name) -}}
{{- end -}}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "acme-issuers.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "acme-issuers.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
