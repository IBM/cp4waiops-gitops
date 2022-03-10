{{/*
Specify the config path for cp4waiops aimanager
*/}}
{{- define "cp4waiops.aimanager.configPath" -}}
  {{- if eq .Values.cp4waiops.version "v3.2" }}
  {{- printf "config/3.2/cp4waiops" -}}
  {{- else if eq .Values.cp4waiops.version "v3.3" }}
  {{- printf "config/3.3/ai-manager" -}}
  {{- else }}
  {{- fail "The CP4WAIOps all in one chart only supports release v3.2, v3.3." }}
  {{- end }}
{{- end -}}

{{/*
Specify the config path for cp4waiops eventmanager
*/}}
{{- define "cp4waiops.eventmanager.configPath" -}}
  {{- if eq .Values.cp4waiops.version "v3.2" }}
  {{- printf "config/3.2/cp4waiops" -}}
  {{- else if eq .Values.cp4waiops.version "v3.3" }}
  {{- printf "config/3.3/event-manager" -}}
  {{- else }}
  {{- fail "The CP4WAIOps all in one chart only supports release v3.2, v3.3." }}
  {{- end }}
{{- end -}}
