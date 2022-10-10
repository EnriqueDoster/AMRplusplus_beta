#!/bin/bash
#SBATCH -J AMR++ -o AMR++.out -t 01:00:00 -p short --ntasks-per-node=2

nextflow run main_AMR++.nf -profile singularity_workshop --reads "/home/training/AMR_workshop_reads/small_subsample/*_{1,2}.fastq.gz" --pipeline standard_AMR
