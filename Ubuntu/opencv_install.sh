#!/bin/bash
# Dan Walkes
# 2014-01-29
# Call this script after configuring variables:
# version - the version of OpenCV to be installed
# downloadfile - the name of the OpenCV download file
# dldir - the download directory (optional, if not specified creates an OpenCV directory in the working dir)
if [[ -z "$version" ]]; then
    echo "Please define version before calling `basename $0` or use a wrapper like opencv_latest.sh"
    exit 1
fi
if [[ -z "$downloadfile" ]]; then
    echo "Please define downloadfile before calling `basename $0` or use a wrapper like opencv_latest.sh"
    exit 1
fi
if [[ -z "$dldir" ]]; then
    dldir=OpenCV
fi
if ! sudo true; then
    echo "You must have root privileges to run this script."
    exit 1
fi
set -e

echo "--- Installing OpenCV" $version

echo "--- Installing Dependencies"
source dependencies.sh

echo "--- Downloading OpenCV" $version
mkdir -p $dldir
cd $dldir
wget -c -O $downloadfile http://sourceforge.net/projects/opencvlibrary/files/opencv-unix/$version/$downloadfile/download

echo "--- Installing OpenCV" $version
echo $downloadfile | grep ".zip"
if [ $? -eq 0 ]; then
    unzip $downloadfile
else
    tar -xvf $downloadfile
fi
cd opencv-$version
mkdir build
cd build
cmake -D CMAKE_BUILD_TYPE=RELEASE \
		-D CMAKE_INSTALL_PREFIX=/usr/local \
		-D INSTALL_PYTHON_EXAMPLES=ON \
		-D INSTALL_C_EXAMPLES=ON \
		-D BUILD_DOCS=ON \
		-D BUILD_TESTS=ON \
		-D BUILD_opencv_python2=ON \
		-D BUILD_opencv_python3=ON \
		-D BUILD_EXAMPLES=ON \
		-D BUILD_NEW_PYTHON_SUPPORT=ON \
		-D WITH_1394=OFF \
		-D WITH_MATLAB=ON \
		-D WITH_OPENCL=ON \
		-D WITH_OPENCLAMDBLAS=OFF \
		-D WITH_OPENCLAMDFFT=OFF \
		-D WITH_QT=ON \
		-D WITH_OPENGL=ON \
		-D WITH_TBB=ON \
		-D WITH_V4L=ON \
		-D PYTHON_EXECUTABLE=/usr/bin/python3 \
		-D PYTHON_INCLUDE=/usr/include/python3.4/ \
		-D PYTHON_LIBRARY=/usr/lib/arm-linux-gnueabihf/libpython3.4m.so \
		-D PYTHON_PACKAGES_PATH=/usr/local/lib/python3.4/site-packages/ \
		-D CMAKE_CXX_FLAGS="-O3 -funsafe-math-optimizations" \
		-D CMAKE_C_FLAGS="-O3 -funsafe-math-optimizations" ..
make -j 4
sudo make install
sudo sh -c 'echo "/usr/local/lib" > /etc/ld.so.conf.d/opencv.conf'
sudo ldconfig
echo "OpenCV" $version "ready to be used"
