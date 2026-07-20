# libmpv-win-video-build

Self-built libmpv for Windows with **libcurl + nghttp2** enabled, providing HTTP/2 multiplexing for HLS streaming.

## Why

Default shinchiro/zhongfly builds don't enable `--enable-libcurl` in ffmpeg, so mpv uses ffmpeg's native HTTPS (no HTTP/2). On Windows this causes slow HLS first-frame (each segment = new TLS handshake). This fork injects libcurl + nghttp2 to let ffmpeg negotiate HTTP/2 via ALPN, reusing a single TLS connection across segments.

Measured first-frame time on `https://v.lzcdn31.com/.../index.m3u8` (Windows, same machine):

| Variant | First frame |
| --- | --- |
| Stock libmpv (no HTTP/2) | ~5.6s |
| Local HTTP/2 proxy + prefetch | ~2.9s |
| **This build (native libcurl/HTTP2)** | TBD |

## Source

- Build system: [shinchiro/mpv-winbuild-cmake](https://github.com/shinchiro/mpv-winbuild-cmake)
- Overlay files in `overlays/packages/`:
  - `nghttp2.cmake` — new, builds libnghttp2 (HTTP/2)
  - `curl.cmake` — modified, switched to openssl + nghttp2 backend, enables `--with-nghttp2` and `--enable-http2`
  - `ffmpeg.cmake` — modified, adds `curl` to DEPENDS and `--enable-libcurl` to configure
  - `CMakeLists.txt` — modified, registers `nghttp2` package
- Architecture: x86_64-v3
- Compiler: clang
- TLS backend: openssl (matches ffmpeg)

## Build

Triggered manually via GitHub Actions (`.github/workflows/build-with-libcurl.yml`).

Go to Actions → "Build libmpv with libcurl/HTTP2" → Run workflow → pick target arch (default `64-v3`).

Build takes ~60-90 minutes on a fresh runner (no cache); ~15-25 minutes with warm cache.

## Releases

See [releases](https://github.com/y21179/libmpv-win-video-build/releases). Replace `libmpv-2.dll` in your media_kit app's `build/windows/x64/runner/Debug/` (or Release) directory.
