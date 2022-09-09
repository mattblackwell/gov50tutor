#!/usr/bin/env bash

# give public key: https://cran.r-project.org/bin/linux/ubuntu/README.html#secure-apt
# update indices
apt update -qq
# install two helper packages we need
apt install --no-install-recommends software-properties-common dirmngr
# add the signing key (by Michael Rutter) for these repos
# To verify key, run gpg --show-keys /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc 
# Fingerprint: E298A3A825C0D65DFD57CBB651716619E084DAB9
wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc
# add the R 4.0 repo from CRAN -- adjust 'focal' to 'groovy' or 'bionic' as needed
add-apt-repository "deb https://cloud.r-project.org/bin/linux/ubuntu $(lsb_release -cs)-cran40/"

# update everything
apt-get update

# now do usual R installation.
apt-get install -y libxml2-dev libcurl4-openssl-dev libssl-dev
apt-get install -y r-base r-base-dev
apt-get install -y libpoppler-cpp-dev poppler-utils

Rscript -e "install.packages('jsonlite')"
Rscript -e "install.packages('pdftools')"
