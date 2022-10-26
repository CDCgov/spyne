#!/usr/bin/env bash

fastqs=$@
sample_name=$(echo $fastqs|cut -f1 |rev|cut -d '/' -f1|rev | cut -d '.' -f1 | cut -d '_' -f1) #change this last pipe

[[ ! -d IRMA ]] && mkdir IRMA 

docker run --rm \
  -v $PWD:/data \
  public.ecr.aws/n3z8t4o2/irma:1.0.2p3 \
  IRMA FLU-minion $fastqs IRMA/$sample_name


