{{/*
Specify the config path
*/}}
{{- define "cp4waiops.configPath" -}}
  {{- if eq .Values.cp4waiops.version "3.2" }}
  {{- printf "config/cp4waiops/3.2" -}}
  {{- else if eq .Values.cp4waiops.version "3.3" }}
  {{- printf "config/cp4waiops/3.3" -}}
  {{- else }}
  {{- printf "config/cp4waiops/3.3" -}}
  {{- end }}
{{- end -}}
