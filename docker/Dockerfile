# Base Image
FROM r-base:3.5.2

# Metadata
LABEL description="Docker image containing all dependencies for PheWAS pipeline: https://github.com/lifebit-ai/PHESANT"

# Maintainer
LABEL Phil Palmer <phil@lifebit.ai>

# Install R dependencies 
RUN Rscript -e "install.packages('optparse', repos = 'http://cran.us.r-project.org')" && \
    Rscript -e "install.packages('forestplot', repos = 'http://cran.us.r-project.org')" && \
    Rscript -e "install.packages('data.table', repos = 'http://cran.us.r-project.org')" && \
    Rscript -e "install.packages('lmtest', repos = 'http://cran.us.r-project.org')"

RUN mkdir /data && \
    mkdir /data/scripts/

COPY ./R/ /data/scripts/

RUN chmod -R u+x /data/scripts

ENV PATH=$PATH:/data/scripts/resultsProcessing 
ENV PATH=$PATH:/data/scripts/WAS

WORKDIR /data/scripts/

