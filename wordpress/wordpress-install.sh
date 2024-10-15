#!/usr/bin/env bash
echo "install wordpress chart"
helm install ustec oci://registry-1.docker.io/bitnamicharts/wordpress --namespace wordpress


