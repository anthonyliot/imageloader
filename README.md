# If issue 'python: error: Failed to locate 'python'
sudo ln -s $(which python3) /usr/local/bin/python

# Standard build
mkdir build
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make 

# Build for Emscripten
mkdir build
cd build
conan install .. -pr:b default -pr:h ../conanfile.emscripten.profile -s build_type=Release -if . -b missing     
cmake .. -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_EMSCRIPTEN=ON
make