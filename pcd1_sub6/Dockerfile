# Use the official Ubuntu base image
FROM ubuntu:focal

# Avoid user interaction with tzdata
ENV DEBIAN_FRONTEND=noninteractive

# Install system dependencies for R
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    libcurl4-gnutls-dev \
    libxml2-dev \
    libssl-dev \
    libfontconfig1-dev \
    libcairo2-dev \
    libxt-dev \
    xorg-dev \
    libreadline-dev \
    libbz2-dev \
    liblzma-dev \
    zlib1g-dev \
    gfortran \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# Download and unpack Python 3.12.4
RUN curl -O https://www.python.org/ftp/python/3.12.4/Python-3.12.4.tgz \
    && tar -xzf Python-3.12.4.tgz \
    && rm Python-3.12.4.tgz

# Configure, build and install Python
RUN cd Python-3.12.4 \
    && ./configure --enable-optimizations --enable-shared \
    && make -j $(nproc) \
    && make altinstall \
    && ldconfig \
    && cd .. \
    && rm -rf Python-3.12.4

# Set Python 3.12.4 as the default python and pip
RUN ln -s /usr/local/bin/python3.12 /usr/bin/python \
    && ln -s /usr/local/bin/pip3.12 /usr/bin/pip

# Install pandas and scikit-learn
RUN pip install pandas==2.2.2
RUN pip install scikit-learn==1.5.1

# Download and extract R source code
RUN curl -O https://cran.r-project.org/src/base/R-4/R-4.4.1.tar.gz \
    && tar -xf R-4.4.1.tar.gz \
    && rm R-4.4.1.tar.gz

# Configure, build, and install R
RUN cd R-4.4.1 \
    && ./configure --enable-R-shlib --with-blas --with-lapack --with-readline \
    && make \
    && make install \
    && cd .. \
    && rm -r R-4.4.1

# Reset DEBIAN_FRONTEND variable
ENV DEBIAN_FRONTEND=

# Install BiocManager and R packages
RUN R -e "install.packages('BiocManager', repos='http://cran.rstudio.com/')"
RUN R -e "BiocManager::install('readr', ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('optparse', ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('vroom', ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('tibble', ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('purrr', ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('dplyr', ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('pbapply', ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('tidyr', ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('stringr', ask=FALSE, update=FALSE)"
RUN R -e "BiocManager::install('RPMM', ask=FALSE, update=FALSE)"

# Set the working directory
WORKDIR /usr/local/bin

# Create directories
RUN mkdir -p data/ inst/extdata/ intermediate/

# Copy necessary files
COPY utils.py .
COPY utils.R .

COPY data/probe_info_epic.rds data/
COPY data/probe_info_others.rds data/
COPY data/beta_train_filter_detp_rownames.rds data/

COPY data/ga_dmp.rds data/
COPY data/ga_res_cpg_pr_dmp.rds data/
COPY data/ga_res_cpg_t_dmp.rds data/

COPY inst/extdata/ga_est_scaler.joblib inst/extdata/
COPY inst/extdata/ga_res_cpg_pr_est_scaler.joblib inst/extdata/
COPY inst/extdata/ga_res_cpg_t_est_scaler.joblib inst/extdata/

COPY inst/extdata/ga_est_best_model.joblib inst/extdata/
COPY inst/extdata/ga_res_cpg_pr_est_best_model.joblib inst/extdata/
COPY inst/extdata/ga_res_cpg_t_est_best_model.joblib inst/extdata/

COPY data_preprocessing.R .
COPY run_model_stage*.py .
COPY run_model_stage*.R .

# Set executable permissions on scripts
RUN chmod a+x *.R *.py

# Define the entry point for the container using JSON array syntax
CMD ["sh", "-c", "Rscript data_preprocessing.R && python run_model_stage1.py && Rscript run_model_stage2.R"]
