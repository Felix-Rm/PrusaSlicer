set -e

if [ -z "$AUTOBUILD_SOURCE_DIR" ]; then
    AUTOBUILD_SOURCE_DIR=".."
fi

if [ -z "$AUTOBUILD_INSTALL_DIR" ]; then
    AUTOBUILD_INSTALL_DIR="install"
fi

if [ -z "$AUTOBUILD_BUILD_DIR" ]; then
    AUTOBUILD_BUILD_DIR="build_linux"
fi

if [ -z "$AUTOBUILD_DEP_BUILD_DIR" ]; then
    AUTOBUILD_DEP_BUILD_DIR="build_dep_linux"
fi

dep_src_dir="$AUTOBUILD_SOURCE_DIR/deps"

cmake -S "$dep_src_dir" -B "$AUTOBUILD_DEP_BUILD_DIR"   \
    -DCMAKE_BUILD_TYPE=Release                          \
    -DCMAKE_C_FLAGS="-Wno-gnu-line-marker"              \
    -DCMAKE_CXX_FLAGS="-Wno-gnu-line-marker"            \
    -DDEP_WX_GTK3=ON                        
cmake --build "$AUTOBUILD_DEP_BUILD_DIR"

cmake -S "$AUTOBUILD_SOURCE_DIR" -B "$AUTOBUILD_BUILD_DIR"                  \
    -DCMAKE_BUILD_TYPE=Release                                              \
    -DCMAKE_EXPORT_COMPILE_COMMANDS=ON                                      \
    -DCMAKE_CXX_FLAGS="-Wno-enum-constexpr-conversion -Wno-gnu-line-marker" \
    -DCMAKE_C_FLAGS="-Wno-gnu-line-marker"                                  \
    -DCMAKE_PREFIX_PATH="$AUTOBUILD_DEP_BUILD_DIR/destdir/usr/local"        \
    -DSLIC3R_STATIC=1                                                       \
    -DSLIC3R_GTK=3                                                          \
    -DSLIC3R_PCH=OFF                                                        
cmake --build "$AUTOBUILD_BUILD_DIR"
cmake --install "$AUTOBUILD_BUILD_DIR" --prefix "$AUTOBUILD_INSTALL_DIR"
