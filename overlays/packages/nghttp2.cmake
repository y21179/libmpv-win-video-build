# nghttp2 - HTTP/2 library
# 用于让 libcurl 支持 HTTP/2 多路复用，从而让 ffmpeg 启用 --enable-libcurl 后
# 能在 HLS 分片下载时复用同一 TLS 连接，显著降低首帧时间。
# 仅构建 libnghttp2（不带 nghttp2.exe / nghttpd / nghttpx 等工具）。
ExternalProject_Add(nghttp2
    GIT_REPOSITORY https://github.com/nghttp2/nghttp2.git
    GIT_TAG v1.57.0
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_CLONE_FLAGS "--filter=tree:0"
    # nghttp2 v1.57.0 的 cmake_minimum_required(VERSION 3.0) 在 CMake 4.0+ 报错
    # （Compatibility with CMake < 3.5 has been removed）。打补丁提高到 3.5。
    PATCH_COMMAND sed -i
        -e "s/cmake_minimum_required(VERSION [0-9]\\.[0-9]\\(\\.[0-9]\\)\\?)/cmake_minimum_required(VERSION 3.5)/"
        <SOURCE_DIR>/CMakeLists.txt
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} CONF=1 cmake -H<SOURCE_DIR> -B<BINARY_DIR>
        -G Ninja
        -DCMAKE_BUILD_TYPE=Release
        -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE}
        -DCMAKE_INSTALL_PREFIX=${MINGW_INSTALL_PREFIX}
        -DCMAKE_FIND_ROOT_PATH=${MINGW_INSTALL_PREFIX}
        -DBUILD_SHARED_LIBS=OFF
        -DENABLE_LIB_ONLY=ON
        -DENABLE_HTTP3=OFF
    BUILD_COMMAND ${EXEC} ninja -C <BINARY_DIR>
    INSTALL_COMMAND ${EXEC} ninja -C <BINARY_DIR> install
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_INSTALL 1
    # 故意不设 LOG_CONFIGURE/LOG_BUILD：让 configure/build 输出直接显示在主日志，
    # 便于在线诊断 configure 失败的具体原因（CMake Error / FATAL_ERROR 等）。
)

force_rebuild_git(nghttp2)
cleanup(nghttp2 install)
