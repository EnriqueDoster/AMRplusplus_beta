

process Qiime2Processing {
    tag { }
    conda = "$baseDir/envs/qiime2.yaml"
    container = 'enriquedoster/amrplusplus_microbiome:latest'
    publishDir "${params.output}/Qiime2Results", mode: "copy"

    input:
        path(ch_manifest)
        path(dada2_db)

    """
    ${qiime} tools import \
      --type 'SampleData[PairedEndSequencesWithQuality]' \
      --input-path ${ch_manifest} \
      --output-path demux.qza \
      --input-format PairedEndFastqManifestPhred33

    ${qiime} dada2 denoise-paired --i-demultiplexed-seqs demux.qza --o-table dada-table.qza --o-representative-sequences rep-seqs.qza --p-trim-left-f 5 --p-trim-left-r 5 --p-trunc-len-f 240 -p-trunc-len-r 240 --p-n-threads ${threads} --verbose

    #${qiime} feature-table summarize --i-table dada-table.qza --m-sample-metadata-file metadata --o-visualization dada-table.qzv
    #${qiime} feature-table tabulate-seqs --i-data rep-seqs.qza --o-visualization rep-seqs.qzv

    """
}

