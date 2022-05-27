{{/*
Specify the config path for cp4waiops aimanager
*/}}
{{- define "cp4waiops.aimanager.configPath" -}}
  {{- if eq .Values.cp4waiops.version "v3.2" }}
  {{- printf "config/3.2/ai-manager" -}}
  {{- else if eq .Values.cp4waiops.version "v3.3" }}
  {{- printf "config/cp4waiops/install-aimgr" -}}
  {{- else if eq .Values.cp4waiops.version "v3.4" }}
  {{- printf "config/cp4waiops/install-aimgr" -}}
  {{- else }}
  {{- fail "The CP4WAIOps all in one chart only supports release v3.2, v3.3, v3.4." }}
  {{- end }}
{{- end -}}

{{/*
Specify the config path for cp4waiops eventmanager
*/}}
{{- define "cp4waiops.eventmanager.configPath" -}}
  {{- if eq .Values.cp4waiops.version "v3.2" }}
  {{- printf "config/3.2/event-manager" -}}
  {{- else if eq .Values.cp4waiops.version "v3.3" }}
  {{- printf "config/cp4waiops/install-emgr" -}}
  {{- else if eq .Values.cp4waiops.version "v3.4" }}
  {{- printf "config/cp4waiops/install-emgr" -}}  
  {{- else }}
  {{- fail "The CP4WAIOps all in one chart only supports release v3.2, v3.3, v3.4." }}
  {{- end }}
{{- end -}}
