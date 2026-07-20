# curl - HTTP/HTTPS client library
# 修改自 shinchiro/mpv-winbuild-cmake 原版：
#   - 后端从 mbedtls 换成 openssl（与 ffmpeg 一致，统一 TLS 栈）
#   - 新增 nghttp2 依赖，启用 HTTP/2 多路复用
#   - 启用 ALPN 协商（openssl 原生支持）
# 目的：让 ffmpeg 通过 --enable-libcurl 走 HTTP/2，优化 HLS 加载速度。
ExternalProject_Add(curl
    DEPENDS
        openssl
        nghttp2
        zlib
        zstd
        brotli
    GIT_REPOSITORY https://github.com/curl/curl.git
    SOURCE_DIR ${SOURCE_LOCATION}
    GIT_CLONE_FLAGS "--filter=tree:0"
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ${EXEC} autoreconf -fi && CONF=1 <SOURCE_DIR>/configure
        --host=${TARGET_ARCH}
        --prefix=${MINGW_INSTALL_PREFIX}
        --disable-shared
        --with-openssl=${MINGW_INSTALL_PREFIX}
        --with-nghttp2=${MINGW_INSTALL_PREFIX}
        --with-zlib=${MINGW_INSTALL_PREFIX}
        --with-brotli=${MINGW_INSTALL_PREFIX}
        --with-zstd=${MINGW_INSTALL_PREFIX}
        --without-mbedtls
        --without-libpsl
        --without-libidn2
        --without-librtmp
        --without-libssh2
        --without-libssh
        --without-gssapi
        --without-nghttp3
        --without-ngtcp2
        --enable-http2
        --disable-ldap
        --disable-ldaps
        --disable-ftp
        --disable-file
        --disable-rtsp
        --disable-dict
        --disable-telnet
        --disable-tftp
        --disable-pop3
        --disable-imap
        --disable-smb
        --disable-smtp
        --disable-gopher
        --disable-manual
        --disable-docs
    BUILD_COMMAND ${MAKE}
    INSTALL_COMMAND ${MAKE} install
    BUILD_IN_SOURCE 1
    LOG_DOWNLOAD 1 LOG_UPDATE 1 LOG_CONFIGURE 1 LOG_BUILD 1 LOG_INSTALL 1
)

force_rebuild_git(curl)
cleanup(curl install)
