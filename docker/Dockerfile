FROM lifebitai/phewas@sha256:b9c42a88254ca126fbb1e3dc4317b41f5681b1f58a1e040fc8ee28f66ea91b5e
# See here for OG Dockerfile: https://github.com/lifebit-ai/PHESANT/blob/536525b983be44a468c098e2d24cb66016a4fae8/docker/Dockerfile
LABEL authors="phil@lifebit.ai" \
      description="Docker image containing all dependencies for Biobak Scanner pipeline: https://github.com/lifebit-ai/PHESANT"

# Install procps so that Nextflow can poll CPU usage
RUN apt-get update && apt-get install -y procps && apt-get clean -y