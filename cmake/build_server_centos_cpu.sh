#! /bin/bash

# debugging and logging
set -x
 
# install Fletch & VIAME system deps
yum update -y
yum -y groupinstall 'Development Tools'
yum install -y zip \
git \
wget \
openssl \
openssl-devel \
zlib \
zlib-devel \
freeglut-devel \
mesa-libGLU-devel \
lapack-devel \
libXt-devel \
libXmu-devel \
libXi-devel \
expat-devel \
readline-devel \
curl \
curl-devel \
atlas-devel \
file \
which

# Install CMAKE
wget https://cmake.org/files/v3.17/cmake-3.17.0.tar.gz
tar zxvf cmake-3.*
cd cmake-3.17.0
./bootstrap --prefix=/usr/local --system-curl
make -j$(nproc)
make install
cd /
rm -rf cmake-3.17.0.tar.gz

# Update VIAME sub git sources
cd /viame/
git submodule update --init --recursive
mkdir build
cd build 

# Configure Paths [should be removed when no longer necessary by fletch]
export PATH=$PATH:/viame/build/install/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/viame/build/install/lib:/viame/build/install/lib/python3.6
export C_INCLUDE_PATH=$C_INCLUDE_PATH:/viame/build/install/include/python3.6m
export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/viame/build/install/include/python3.6m

# Configure VIAME
cmake ../ -DCMAKE_BUILD_TYPE:STRING=Release \
-DVIAME_BUILD_DEPENDENCIES:BOOL=ON \
-DVIAME_CREATE_PACKAGE:BOOL=ON \
-DVIAME_ENABLE_BURNOUT:BOOL=OFF \
-DVIAME_ENABLE_CAFFE:BOOL=OFF \
-DVIAME_ENABLE_CAMTRAWL:BOOL=ON \
-DVIAME_ENABLE_CUDA:BOOL=OFF \
-DVIAME_ENABLE_CUDNN:BOOL=OFF \
-DVIAME_ENABLE_DOCS:BOOL=OFF \
-DVIAME_ENABLE_FFMPEG:BOOL=ON \
-DVIAME_ENABLE_FFMPEG-X264:BOOL=ON \
-DVIAME_ENABLE_GDAL:BOOL=ON \
-DVIAME_ENABLE_FLASK:BOOL=OFF \
-DVIAME_ENABLE_ITK:BOOL=OFF \
-DVIAME_ENABLE_KWANT:BOOL=ON \
-DVIAME_ENABLE_KWIVER:BOOL=ON \
-DVIAME_ENABLE_MATLAB:BOOL=OFF \
-DVIAME_ENABLE_OPENCV:BOOL=ON \
-DVIAME_ENABLE_PYTHON:BOOL=ON \
-DVIAME_ENABLE_PYTHON-INTERNAL:BOOL=ON \
-DVIAME_ENABLE_PYTORCH:BOOL=ON \
-DVIAME_ENABLE_PYTORCH-INTERNAL:BOOL=OFF \
-DVIAME_ENABLE_PYTORCH-MMDET:BOOL=ON \
-DVIAME_ENABLE_PYTORCH-NETHARN:BOOL=ON \
-DVIAME_ENABLE_PYTORCH-PYSOT:BOOL=OFF \
-DVIAME_ENABLE_SCALLOP_TK:BOOL=OFF \
-DVIAME_ENABLE_SEAL_TK:BOOL=OFF \
-DVIAME_ENABLE_SMQTK:BOOL=ON \
-DVIAME_ENABLE_TENSORFLOW:BOOL=OFF \
-DVIAME_ENABLE_UW_PREDICTOR:BOOL=OFF \
-DVIAME_ENABLE_VIVIA:BOOL=ON \
-DVIAME_ENABLE_VXL:BOOL=ON \
-DVIAME_ENABLE_YOLO:BOOL=ON 

# Build VIAME first attempt
make -j$(nproc) -k || true

# Below be krakens
# (V) (°,,,°) (V)   (V) (°,,,°) (V)   (V) (°,,,°) (V)

# HACK: Double tap the build tree
# Should be removed when non-determinism in kwiver python build fixed
make -j$(nproc)

# HACK: Copy setup_viame.sh.install over setup_viame.sh
# Should be removed when this issue is fixed
cp ../cmake/setup_viame.sh.install install/setup_viame.sh

# HACK: Ensure invalid libsvm symlink isn't created
# Should be removed when this issue is fixed
rm install/lib/libsvm.so
cp install/lib/libsvm.so.2 install/lib/libsvm.so

# HACK: Copy in CUDA dlls missed by create_package
# Should be removed when this issue is fixed
cp -P /usr/local/cuda/lib64/libcudart.so* install/lib
cp -P /usr/local/cuda/lib64/libcusparse.so* install/lib
cp -P /usr/local/cuda/lib64/libcufft.so* install/lib
cp -P /usr/local/cuda/lib64/libcusolver.so* install/lib
cp -P /usr/local/cuda/lib64/libnvrtc* install/lib
cp -P /usr/local/cuda/lib64/libnvToolsExt.so* install/lib

# HACK: Copy in other possible library requirements if present
# Should be removed when this issue is fixed
cp /usr/lib64/libva.so.1 install/lib || true
cp /usr/lib64/libreadline.so.6 install/lib || true
cp /usr/lib64/libdc1394.so.22 install/lib || true
cp /usr/lib64/libcrypto.so.10 install/lib || true
cp /usr/lib64/libpcre.so.1 install/lib || true
cp /usr/lib64/libgomp.so.1 install/lib || true
cp /usr/lib64/libSM.so.6 install/lib || true
cp /usr/lib64/libICE.so.6 install/lib || true
cp /usr/lib64/libblas.so.3 install/lib || true
cp /usr/lib64/liblapack.so.3 install/lib || true
cp /usr/lib64/libgfortran.so.3 install/lib || true
cp /usr/lib64/libquadmath.so.0 install/lib || true

# HACK: CPU Online Models
wget https://data.kitware.com/api/v1/item/5e33b852af2e2eed35535b92/download
mv download download.tar.gz
tar -xvf download.tar.gz

#cp /usr/lib64/libX11.so.6 install/lib || true
#cp /usr/lib64/libXau.so.6 install/lib || true
#cp /usr/lib64/libxcb.so.1 install/lib || true
#cp /usr/lib64/libXext.so.6 install/lib || true
