
// resistome
include { Qiime2Processing} from '../modules/Microbiome/qiime2'


workflow FASTQ_QIIME2_WF {
    take: 
        ch_manifest
        dada2_db
        
    main:
        Qiime2Processing(ch_manifest,dada2_db)        

}
