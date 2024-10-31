# Start with the official Miniconda base image to avoid manual Miniconda installation
FROM continuumio/miniconda3:latest

# Install CUDA dependencies and set environment variables for CUDA
RUN apt-get update && apt-get install -y \
    curl \
    git \
    bzip2 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install CUDA runtime and cuDNN from NVIDIA repositories
RUN curl -sSL https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-keyring_1.0-1_all.deb -o cuda-keyring.deb && \
    dpkg -i cuda-keyring.deb && \
    rm cuda-keyring.deb && \
    apt-get update && \
    apt-get install -y cuda-libraries-11-8 cuda-nvrtc-11-8 libcudnn8=8.4.1.*-1+cuda11.8 && \
    rm -rf /var/lib/apt/lists/*

# Set environment variables for CUDA
ENV PATH="/usr/local/cuda/bin:$PATH" \
    CUDA_HOME="/usr/local/cuda"

# Clone the BindCraft repository
WORKDIR /app
RUN git clone https://github.com/martinpacesa/BindCraft .

# Run the BindCraft installation script with the specified CUDA version and package manager
RUN bash install_bindcraft.sh --cuda '11.8' --pkg_manager 'conda' && \
    conda clean -afy

# Define the default command to keep the container running
CMD ["bash"]
