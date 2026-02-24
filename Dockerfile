FROM rocker/r-ver:4.3.1

RUN apt-get update && apt-get install -y --no-install-recommends     libcurl4-openssl-dev libssl-dev libxml2-dev libgit2-dev     && rm -rf /var/lib/apt/lists/*

WORKDIR /work
COPY . /work

RUN R -e "install.packages('renv', repos='https://cloud.r-project.org')"
CMD ["/bin/bash"]
