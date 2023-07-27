# FROM nvidia/cuda:12.2.0-devel-ubuntu22.04
FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04

ARG COLMAP_VERSION=dev
ARG CUDA_ARCHITECTURES=native
ENV QT_XCB_GL_INTEGRATION=xcb_egl

# Prevent stop building ubuntu at time zone selection.  
ENV DEBIAN_FRONTEND=noninteractive

# Prepare and empty machine for building.
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    ninja-build \
    build-essential \
    libboost-program-options-dev \
    libboost-filesystem-dev \
    libboost-graph-dev \
    libboost-system-dev \
    libeigen3-dev \
    libflann-dev \
    libfreeimage-dev \
    libmetis-dev \
    libgoogle-glog-dev \
    libgtest-dev \
    libsqlite3-dev \
    libglew-dev \
    qtbase5-dev \
    libqt5opengl5-dev \
    libcgal-dev \
    libceres-dev

# Build and install COLMAP.
RUN git clone https://github.com/colmap/colmap.git
RUN cd colmap && \
    git reset --hard ${COLMAP_VERSION} && \
    mkdir build && \
    cd build && \
    cmake .. -GNinja -DCMAKE_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES} && \
    ninja && \
    ninja install && \
    cd .. && rm -rf colmap

# Install ImageMagick
RUN apt-get update && apt-get install -y imagemagick wget

# Install conda and pytorch 
RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh 

ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN conda --version

RUN conda init bash \
    && . ~/.bashrc \
    && conda create -n f2nerf python=3.8 \
    && conda activate f2nerf \
    && conda install pytorch==1.13.1 torchvision==0.14.1 pytorch-cuda=11.7 -c pytorch -c nvidia \
    && conda clean --all

# Install f2-nerf
# Install the required packages
RUN apt-get update \
    && apt-get install -y ffmpeg libsm6 libxext6 git ninja-build libglib2.0-0 libsm6 libxrender-dev libxext6 zlib1g-dev wget  zip unzip cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN conda clean --all \
    && git clone --recursive https://github.com/chuong98/f2-nerf.git /f2-nerf
    
WORKDIR /f2-nerf/External
# COPY External/libtorch-cxx11-abi-shared-with-deps-1.13.1+cu117.zip /f2-nerf/External
RUN wget https://download.pytorch.org/libtorch/cu117/libtorch-cxx11-abi-shared-with-deps-1.13.1%2Bcu117.zip
RUN unzip ./libtorch-cxx11-abi-shared-with-deps-1.13.1+cu117.zip 

# Build
WORKDIR /f2-nerf

# RUN mkdir build
RUN cmake . -B build # -D TCNN_CUDA_ARCHITECTURES=86 -D CMAKE_CUDA_COMPILER=$(which nvcc)
RUN cmake . -B build \
    && cmake --build build --target main --config RelWithDebInfo -j
RUN rm /f2-nerf/External/libtorch-cxx11-abi-shared-with-deps-1.13.1+cu117.zip