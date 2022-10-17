// Resistome

if( params.annotation ) {
    annotation = file(params.annotation)
    if( !annotation.exists() ) return annotation_error(annotation)
}

threshold = params.threshold

min = params.min
max = params.max
skip = params.skip
samples = params.samples

process build_dependencies {
    tag { dl_github }
    label "python"

    publishDir "${baseDir}/bin/", mode: "copy"

    output:
        path("rarefaction"), emit: rarefactionanalyzer
        path("resistome"), emit: resistomeanalyzer
        path("AmrPlusPlus_SNP/*"), emit: amrsnp

    """
    # Uncomment these sections once the v2 rarefactionanalyzer and resistomeanalyzer repositories are updated, remove cp lines
    #git clone https://github.com/cdeanj/rarefactionanalyzer.git
    #cd rarefactionanalyzer
    #make
    #chmod 777 rarefaction
    #mv rarefaction ../
    #cd ../
    #rm -rf rarefactionanalyzer
    cp $baseDir/bin/rarefaction . 


    #git clone https://github.com/cdeanj/resistomeanalyzer.git
    #cd resistomeanalyzer
    #make
    #chmod 777 resistome
    #mv resistome ../
    #cd ../
    #rm -rf resistomeanalyzer
    cp $baseDir/bin/resistome .

    git clone https://github.com/Isabella136/AmrPlusPlus_SNP.git

    """


}






process runresistome {
    tag { sample_id }
    label "python"

    publishDir "${params.output}/RunResistome", mode: "copy"

    input:
        tuple val(sample_id), path(sam)
        path(amr)
        path(annotation)
        path(resistome)

    output:
        tuple val(sample_id), path("${sample_id}*.tsv"), emit: resistome_tsv
        path("${sample_id}.gene.tsv"), emit: resistome_counts

    
    
    """
    $resistome -ref_fp ${amr} \
      -annot_fp ${annotation} \
      -sam_fp ${sam} \
      -gene_fp ${sample_id}.gene.tsv \
      -group_fp ${sample_id}.group.tsv \
      -mech_fp ${sample_id}.mechanism.tsv \
      -class_fp ${sample_id}.class.tsv \
      -type_fp ${sample_id}.type.tsv \
      -t ${threshold}
    """
}


process runsnp {
    tag {sample_id}
    label "python"

    publishDir "${params.output}/RunSNP_Verification", mode: "copy"

    errorStrategy = 'ignore'

    input:
        tuple val(sample_id), path(sam_resistome)
        path(amrsnp)
        path(snp_count_matrix)

    output:
        path("${sample_ID}_SNP_count_col"), emit: snp_counts

    """
    mv ${sam_resistome} AmrPlusPlus_SNP/
    mv ${snp_count_matrix} AmrPlusPlus_SNP/
    cd AmrPlusPlus_SNP/
    python3 SNP_Verification.py -c config.ini -a -i ${sam_resistome} -o ${sample_id}_SNPs --count_matrix ${snp_count_matrix}

    awk -v RS=',' "/${sample_ID}/{print NR; exit}" ${snp_count_matrix}
    col_num=$(awk -v RS=',' "/${sample_ID}/{print NR; exit}" ${snp_count_matrix})
    cut -d ',' -f $col_num ${snp_count_matrix} > ${sample_ID}_SNP_count_col

    """
}


process snpresults {
    tag {sample_id}
    label "python"

    publishDir "${params.output}/RunSNP_Verification", mode: "copy"

    errorStrategy = 'ignore'

    input:
        path(snp_counts)
        path(snp_count_matrix)

    output:
        path("SNPconfirmed_AMR_analytic_matrix.csv"), emit: snp_matrix

    """

    cut -d ',' -f 1 ${snp_count_matrix} > gene_accession_labels
    paste gene_accession_labels ${snp_counts} > SNPconfirmed_AMR_analytic_matrix.csv


    """
}



process resistomeresults {
    tag { }
    label "python"

    publishDir "${params.output}/ResistomeResults", mode: "copy"

    input:
        path(resistomes)

    output:
        path("AMR_analytic_matrix.csv"), emit: raw_count_matrix
        path("AMR_analytic_matrix.csv"), emit: snp_count_matrix, optional: true

    """
    ${PYTHON3} $baseDir/bin/amr_long_to_wide.py -i ${resistomes} -o AMR_analytic_matrix.csv
    """
}

process runrarefaction {
    tag { sample_id }
    label "python"

    publishDir "${params.output}/RunRarefaction", mode: "copy"

    input:
        tuple val(sample_id), path(sam)
        path(annotation)
        path(amr)
        path(rarefaction)

    output:
        path("*.tsv"), emit: rarefaction

    """
    $rarefaction \
      -ref_fp ${amr} \
      -sam_fp ${sam} \
      -annot_fp ${annotation} \
      -gene_fp ${sample_id}.gene.tsv \
      -group_fp ${sample_id}.group.tsv \
      -mech_fp ${sample_id}.mech.tsv \
      -class_fp ${sample_id}.class.tsv \
      -type_fp ${sample_id}.type.tsv \
      -min ${min} \
      -max ${max} \
      -skip ${skip} \
      -samples ${samples} \
      -t ${threshold}
    """
}

process plotrarefaction {
    tag { sample_id }
    label "python"

    publishDir "${params.output}/RarefactionFigures", mode: "copy"

    input:
        path(rarefaction)

    output:
        path("graphs/*.png"), emit: plots

    """
    mkdir data/
    mv *.tsv data/
    mkdir graphs/
    python $baseDir/bin/rfplot.py --dir ./data --nd --s --sd ./graphs
    """
}
