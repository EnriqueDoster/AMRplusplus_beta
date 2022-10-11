#!/bin/bash
#SBATCH -J AMR++ -o AMR++.out -t 01:00:00 -p short --ntasks-per-node=2 --mem 2G

# This script works on TAMU's HPRC, but you need to follow the instructions on the Github to get the right conda 
# environment installed on your computing environment

nextflow run main_AMR++.nf -profile conda_slurm --reads "/home/training/AMR_workshop_reads/small_subsample/*_{1,2}.fastq.gz" --pipeline standard_AMR
