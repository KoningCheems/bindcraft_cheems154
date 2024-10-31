# Start with a CUDA-compatible base image
FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04

# Install essential tools and dependencies
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    libgfortran5 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda for package management
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy

# Set Conda environment and CUDA paths
ENV PATH="/opt/conda/bin:$PATH"
ENV CUDA_HOME="/usr/local/cuda"

# Create and activate the Conda environment for BindCraft
RUN conda create -n bindcraft-conda python=3.9 && \
    echo "source activate bindcraft-conda" > ~/.bashrc

# Install BindCraft dependencies through Conda
RUN conda install -n bindcraft-conda -c conda-forge \
    pandas numpy=1.26.4 biopython==1.79 scipy=1.10.1 \
    seaborn tqdm jupyter ffmpeg && \
    conda clean -afy

# Install JAX with CUDA 11 support
RUN pip install jax[cuda11_pip] -f https://storage.googleapis.com/jax-releases/jax_cuda_releases.html

# Clone BindCraft repository and install PyRosetta manually
WORKDIR /app
RUN git clone https://github.com/martinpacesa/BindCraft && \
    curl -L -o pyrosetta.whl 'https://graylab.jhu.edu/download/PyRosetta4/archive/release/PyRosetta4.Release.python39.ubuntu.wheel/pyrosetta-2024.38+release.200d5f9a7d-cp39-cp39-linux_x86_64.whl' && \
    pip install ./pyrosetta.whl && rm pyrosetta.whl

# Final BindCraft installation steps
RUN bash BindCraft/install_bindcraft.sh --cuda '11.8' --pkg_manager 'conda'

# Default command
CMD ["bash"]
