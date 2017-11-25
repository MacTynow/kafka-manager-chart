{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "kafka-manager.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "kafka-manager.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
Resolve the name of the service based on the user configuration
Will either yield a fixed name (.Values.service.fixed.enabled) or
one parametrized with the release.
*/}}

{{- define "kafka-manager.servicename" -}}
{{- if .Values.service.fixed.enabled -}}
{{- required "A valid service name is required when fixed mode if enabled" .Values.service.fixed.name -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Handle Zookeeper cluster hosts configurations. It can either be the first
zk cluster of the configured kafkas or a uri to a distant cluster.
*/}}

{{- define "kafka-manager.zkHosts" -}}
  {{- if not .Values.kafka.clusters -}}
    {{- required "A valid .Values.kafkaManager.zkHosts is required when kafka clusters are not configured" .Values.kafkaManager.zkHosts -}}
  {{- else -}}
    {{- if .Values.kafkaManager.useKafkaZookeeper -}}
      {{- required "Need first cluster zkHosts to be set when using kafka zookeeper as kafka-manager backend" ((index .Values.kafka.clusters 0).zkHosts) -}}
    {{- else -}}
      {{- required ".Values.kafkaManager.zkHosts must be configured if not connecting to kafka zookeeper instances" .Values.kafkaManager.zkHosts -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
Generate a curl command with parameters of the cluster to feed the API.
*/}}
{{- define "kafka-manager.bootstrapShellCommand" -}}
  {{- range $cluster := .Values.kafka.clusters -}}
    {{- printf "curl http://%s/clusters -X POST " (include "kafka-manager.servicename" $) -}}
    {{- range $k, $v := $cluster -}}
      {{- printf "-d %s=%s " $k $v -}}
    {{- end -}}
    {{- printf "|| exit 1;" -}}
  {{- end -}}
{{- end -}}
