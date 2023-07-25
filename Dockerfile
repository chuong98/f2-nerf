ARG PYTORCH="2.0.1"
ARG CUDA="11.7"
ARG CUDNN="8"

FROM pytorch/pytorch:${PYTORCH}-cuda${CUDA}-cudnn${CUDNN}-devel

ENV TORCH_CUDA_ARCH_LIST="6.0 6.1 7.0 7.5 8.0 8.6+PTX" \
    TORCH_NVCC_FLAGS="-Xfatbin -compress-all" \
    CMAKE_PREFIX_PATH="$(dirname $(which conda))/../" \
    FORCE_CUDA="1"\
    DEBIAN_FRONTEND="noninteractive"

# Avoid Public GPG key error
# https://github.com/NVIDIA/nvidia-docker/issues/1631
#     && rm /etc/apt/sources.list.d/nvidia-ml.list \
# RUN rm /etc/apt/sources.list.d/cuda.list \
#     && apt-key del 7fa2af80 \
#     && apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub \
#     && apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/7fa2af80.pub

# (Optional, use Mirror to speed up downloads)
# RUN sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//http:\/\/mirrors.aliyun.com\/ubuntu\//g' /etc/apt/sources.list && \
#    pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple

# Install the required packages
RUN apt-get update \
    && apt-get install -y ffmpeg libsm6 libxext6 git ninja-build libglib2.0-0 libsm6 libxrender-dev libxext6 zlib1g-dev wget  zip unzip cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN conda install pytorch==1.13.1 torchvision==0.14.1 pytorch-cuda=11.7 -c pytorch -c nvidia \
    && conda clean --all

# Install ff2-nerf
RUN conda clean --all \
    && git clone --recursive https://github.com/Totoro97/f2-nerf.git /f2-nerf
    
WORKDIR /f2-nerf/External
COPY External/libtorch-cxx11-abi-shared-with-deps-1.13.1+cu117.zip /f2-nerf/External
RUN unzip ./libtorch-cxx11-abi-shared-with-deps-1.13.1+cu117.zip 

# Build
WORKDIR /f2-nerf

# RUN mkdir build
RUN cmake . -B build # -D TCNN_CUDA_ARCHITECTURES=86 -D CMAKE_CUDA_COMPILER=$(which nvcc)
RUN cmake . -B build \
    && cmake --build build --target main --config RelWithDebInfo -j
RUN rm /f2-nerf/External/libtorch-cxx11-abi-shared-with-deps-1.13.1+cu117.zip

COPY requirements.txt /f2-nerf
RUN pip install -r requirements.txt