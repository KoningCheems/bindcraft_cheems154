# Use a minimal CUDA runtime image
FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04

# Install required dependencies (curl for downloading files) and clean up after installation
RUN apt-get update && apt-get install -y \
    curl \
    bzip2 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download and install Miniconda with retries in case of network issues
RUN curl -L https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o /tmp/miniconda.sh --retry 5 --retry-delay 10 && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy

# Update PATH environment variable for conda
ENV PATH="/opt/conda/bin:$PATH"

# Set environment variables for CUDA
ENV CUDA_HOME=/usr/local/cuda

# Clone the BindCraft repository
WORKDIR /app
RUN git clone https://github.com/martinpacesa/BindCraft .

# Run the BindCraft installation script, specifying the CUDA version and package manager
RUN bash install_bindcraft.sh --cuda '11.8' --pkg_manager 'conda' && \
    conda clean -afy

# Set the default command to bash
CMD ["bash"]
