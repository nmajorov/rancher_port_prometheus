#!/usr/bin/env bash

kubectl port-forward service/frontend  8080:80 -n fleet-local


