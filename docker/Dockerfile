# Base Image
FROM r-base:3.5.2

# Metadata
LABEL description="Docker image containing all dependencies for PheWAS pipeline: https://github.com/lifebit-ai/PHESANT"

# Maintainer
LABEL Phil Palmer <phil@lifebit.ai>

# Install R dependencies 
RUN Rscript -e "install.packages('optparse')" && \
    Rscript -e "install.packages('forestplot')" && \
    Rscript -e "install.packages('data.table')" && \
    Rscript -e "install.packages('lmtest')"

RUN mkdir /data && \
    mkdir /data/scripts/

COPY ./R/ /data/scripts/

RUN chmod -R u+x /data/scripts

ENV PATH=$PATH:/data/scripts/

WORKDIR /data/scripts/

