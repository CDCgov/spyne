#!/usr/bin/env bash

fastqs=$@
sample_name=$(echo $fastqs|cut -f1 |rev|cut -d '/' -f1|rev | cut -d '.' -f1 ) #change this last pipe
sample_name=${sample_name%"_bartrim_lr_cutadapt_subsampled"}
[[ ! -d IRMA ]] && mkdir IRMA 

IRMA FLU-minion $fastqs IRMA/$sample_name


