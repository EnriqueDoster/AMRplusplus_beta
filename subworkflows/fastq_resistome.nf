// Load modules
include { index ; bwa_align } from '../modules/Alignment/bwa'

// resistome
include {plotrarefaction ; runresistome ; runsnp ; resistomeresults ; runrarefaction ; build_dependencies ; snpresults} from '../modules/Resistome/resistome'


workflow FASTQ_RESISTOME_WF {
    take: 
        read_pairs_ch
        amr
        annotation

    main:
        // download resistome and rarefactionanalyzer
        if (file("${baseDir}/bin/AmrPlusPlus_SNP/SNP_Verification.py").isEmpty()){
            build_dependencies()
            resistomeanalyzer = build_dependencies.out.resistomeanalyzer
            rarefactionanalyzer = build_dependencies.out.rarefactionanalyzer
            // Index
            index(amr)
            // AMR alignment
            bwa_align(amr, index.out, read_pairs_ch )
            runresistome(bwa_align.out.bwa_sam,amr, annotation, resistomeanalyzer )
            resistomeresults(runresistome.out.resistome_counts.collect())
            if (params.snp == "Y") {
                runsnp(bwa_align.out.bwa_sam, resistomeresults.out.snp_count_matrix)
                snpresults(runsnp.out.snp_counts.collect(), resistomeresults.out.snp_count_matrix )
           }
            runrarefaction(bwa_align.out.bwa_sam, annotation, amr, rarefactionanalyzer)
            plotrarefaction(runrarefaction.out.rarefaction.collect())
        }
        else {
            amrsnp = file("${baseDir}/bin/AmrPlusPlus_SNP/")
            resistomeanalyzer = file("${baseDir}/bin/resistome")
            rarefactionanalyzer = file("${baseDir}/bin/rarefaction")
            // Index
            index(amr)
            // AMR alignment
            bwa_align(amr, index.out, read_pairs_ch )
            runresistome(bwa_align.out.bwa_sam,amr, annotation, resistomeanalyzer )
            resistomeresults(runresistome.out.resistome_counts.collect())
            if (params.snp == "Y") {
                runsnp(bwa_align.out.bwa_sam, resistomeresults.out.snp_count_matrix) 
                snpresults(runsnp.out.snp_counts.collect(), resistomeresults.out.snp_count_matrix )
           }
            runrarefaction(bwa_align.out.bwa_sam, annotation, amr, rarefactionanalyzer)
            plotrarefaction(runrarefaction.out.rarefaction.collect())
        }


}
