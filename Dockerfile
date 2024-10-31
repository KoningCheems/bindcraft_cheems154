# Start with an official CUDA base image
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# Install essential tools and dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    bzip2 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download and install a specific version of Miniconda to avoid 'latest' issues
RUN curl -L https://repo.anaconda.com/miniconda/Miniconda3-py39_4.10.3-Linux-x86_64.sh -o /tmp/miniconda.sh --retry 5 --retry-delay 10 && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy

# Set up environment variables for Conda and CUDA
ENV PATH="/opt/conda/bin:$PATH" \
    CUDA_HOME="/usr/local/cuda" \
    MAMBA_ROOT_PREFIX="/opt/conda"

# Install micromamba as a faster alternative to Conda for package resolution
RUN /opt/conda/bin/conda install -c conda-forge micromamba && \
    /opt/conda/bin/conda clean -afy

# Create the Conda environment and install basic BindCraft dependencies
RUN micromamba create -n bindcraft-env -c conda-forge -c bioconda python=3.9 numpy=1.26.4 biopython=1.79 scipy=1.10.1 seaborn && \
    micromamba clean -afy

# Install JAX with pip in a separate step to isolate dependencies
RUN /opt/conda/envs/bindcraft-env/bin/pip install jax[cuda11_pip] -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html

# Set working directory and clone the BindCraft repository
WORKDIR /app
RUN git clone https://github.com/martinpacesa/BindCraft .
RUN ls -la /app  # Check that files were cloned

# Ensure the install script has executable permissions and run it
RUN chmod +x install_bindcraft.sh && bash install_bindcraft.sh --cuda '11.8' --pkg_manager 'micromamba'

# Define the default command
CMD ["bash"]
