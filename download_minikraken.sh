# Install nextflow if you don't want to install conda
# curl -s https://get.nextflow.io | bash


# Download minikraken database and unzip
wget ftp://ftp.ccb.jhu.edu/pub/data/kraken2_dbs/minikraken_8GB_202003.tgz
tar -xvzf minikraken_8GB_202003.tgz

wget https://data.qiime2.org/2023.2/common/silva-138-99-515-806-nb-classifier.qza
mv silva-138-99-515-806-nb-classifier.qza data/qiime/