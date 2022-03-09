{{/*
Specify the config path
*/}}
{{- define "cp4waiops.configPath" -}}
  {{- if eq .Values.cp4waiops.version "v3.2" }}
  {{- printf "config/3.2/cp4waiops" -}}
  {{- else if eq .Values.cp4waiops.version "v3.3" }}
  {{- printf "config/3.3/ai-manager" -}}
  {{- else }}
  {{- printf "config/3.3/ai-manager" -}}
  {{- end }}
{{- end -}}

{{- define "eventmanager.configPath" -}}
  {{- if eq .Values.cp4waiops.version "v3.2" }}
  {{- printf "config/3.2/cp4waiops" -}}
  {{- else if eq .Values.cp4waiops.version "v3.3" }}
  {{- printf "config/3.3/event-manager" -}}
  {{- else }}
  {{- printf "config/3.3/event-manager" -}}
  {{- end }}
{{- end -}}