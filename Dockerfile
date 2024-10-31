# Use a minimal CUDA runtime image with a version that is known to be available
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# Install required dependencies and clean up after
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    bzip2 \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda and clean up after
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy

# Update PATH environment variable for conda
ENV PATH="/opt/conda/bin:$PATH"

# Set environment variables for CUDA
ENV CUDA_HOME=/usr/local/cuda

# Clone BindCraft repository
WORKDIR /app
RUN git clone https://github.com/martinpacesa/BindCraft .

# Run the BindCraft installation script with minimal dependencies and clean up
RUN bash install_bindcraft.sh --cuda '11.8' --pkg_manager 'conda' && \
    conda clean -afy

# Define default command
CMD ["bash"]
