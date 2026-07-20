# nghttp2 - HTTP/2 library
# 用于让 libcurl 支持 HTTP/2 多路复用，从而让 ffmpeg 启用 --enable-libcurl 后
# 能在 HLS 分片下载时复用同一 TLS 连接，显著降低首帧时间。
# 仅构建 libnghttp2（不带 nghttp2.exe / nghttpd / nghttpx 等工具）。
ExternalProject_Add(nghttp2
    GIT_REPOSITORY https://github.com/nghttp2/nghttp2.git
    GIT_TAG v1.57.0
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_CLONE_FLAGS "--filter=tree:0"
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
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

force_rebuild_git(nghttp2)
cleanup(nghttp2 install)
