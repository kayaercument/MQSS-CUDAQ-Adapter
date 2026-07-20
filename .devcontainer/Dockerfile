FROM --platform=x86_64 python:3.11-bookworm

#ENV TZ="Europe/Berlin"

RUN apt-get update -y && \
    apt-get autoremove -y

RUN apt-get install -y software-properties-common bash-completion cmake build-essential iputils-ping rsync p7zip-full libuv1-dev git librabbitmq-dev libboost-dev libgtest-dev pybind11-dev libgmock-dev flex bison

RUN git clone --branch v3.12.0 https://github.com/nlohmann/json.git && cd json/ && mkdir build && cd build && cmake .. -DJSON_BuildTests=OFF && make install && cd ../.. && rm -rf json

ENV CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

WORKDIR /home

CMD ["bash"]


#RUN apt-get install -y software-properties-common bash-completion cmake build-essential iputils-ping rsync p7zip-full libuv1-dev git nlohmann-json3-dev librabbitmq-dev libboost-dev libgtest-dev pybind11-dev libgmock-dev flex bison


#RUN apt install software-properties-common
#ARG base_image=ubuntu:22.04
#FROM --platform=x86_64 ${base_image} AS prereqs
#SHELL ["/bin/bash", "-c"]
#ARG toolchain=gcc11

# Update and install basic packages
#RUN apt-get update && apt-get install -y --no-install-recommends \
#    ca-certificates \
#    python3 python3-dev python3-pip \
#    wget git unzip curl \
#    software-properties-common gnupg lsb-release \
#    build-essential cmake ninja-build pkg-config \
#    libz3-dev libgtest-dev libssl-dev \
#    libblas-dev libzstd-dev libeigen3-dev \
#    libboost-program-options-dev libcurl4-openssl-dev libzip-dev \
#    bison flex autoconf nlohmann-json3-dev pybind11-dev libfmt-dev\
#    && python3 -m pip install --no-cache-dir numpy \
#    && rm -rf /var/lib/apt/lists/*

#ENV CC=/usr/bin/clang-16
#ENV CXX=/usr/bin/clang++-16

# Set up Git config and clone required repos
#RUN git config --global gc.auto 0 && \
#    git clone https://github.com/NVIDIA/cuda-quantum.git /workspaces/cuda-quantum && cd /workspaces/cuda-quantum && \
#        git checkout releases/v0.14.0 && LLVM_INSTALL_PREFIX=/usr/local/llvm ZLIB_INSTALL_PREFIX=/usr/local/zlib bash /workspaces/cuda-quantum/scripts/install_prerequisites.sh -m
        
        
#&& ZLIB_INSTALL_PREFIX=/usr/local/zlib bash /workspaces/cuda-quantum/scripts/install_prerequisites.sh -m

        
#cmake .. -DMLIR_DIR=/usr/lib/llvm-16/lib/cmake/mlir -DLLVM_DIR=/usr/lib/llvm-16/lib/cmake/llvm -G Ninja -DCUDAQ_BUILD_TESTS=OFF -DCUDAQ_DISABLE_CPP_FRONTEND=OFF -DZLIB_ROOT=/home/di93coc/cuda-q-development/install/zlib -DBLAS_ROOT=/home/di93coc/cuda-q-development/install/blas


#cmake .. -G Ninja   -DLLVM_DIR=/home/di93coc/cuda-q-development/install/llvm/lib/cmake/llvm   -DZLIB_ROOT=/home/di93coc/cuda-q-development/install/zlib   -DBLAS_LIBRARIES=/home/di93coc/cuda-q-development/install/blas/libblas.a -DCMAKE_CXX_FLAGS="-Wno-error" 

#ZLIB_INSTALL_PREFIX=/home/di93coc/cuda-q-development/install/zlib \
#NANOBIND_INSTALL_PREFIX=/home/di93coc/cuda-q-development/install/nanobind \
#LLVM_INSTALL_PREFIX=/home/di93coc/cuda-q-development/install/llvm \
#BLAS_INSTALL_PREFIX=/home/di93coc/cuda-q-development/install/blas \
#OPENSSL_INSTALL_PREFIX=/home/di93coc/cuda-q-development/install/openssl \
#CURL_INSTALL_PREFIX=/home/di93coc/cuda-q-development/install/curl \
#AWS_INSTALL_PREFIX=/home/di93coc/cuda-q-development/install/aws \
#QRMI_INSTALL_PREFIX=/home/di93coc/cuda-q-development/install/qrmi \
#CUQUANTUM_INSTALL_PREFIX=/home/di93coc/cuda-q-development/install/cuquantum \
#CUTENSOR_INSTALL_PREFIX=/home/di93coc/cuda-q-development/install/cutensor \
#bash ../install_prerequisites.sh 