ARG SOURCE_DIR=/neovim
FROM ubuntu:20.04 AS build

ENV DEBIAN_FRONTEND=noninteractive
RUN sed -i -e 's@//ports.ubuntu.com/\? @//ports.ubuntu.com/ubuntu-ports @g' -e 's@//ports.ubuntu.com@//mirrors.ustc.edu.cn@g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get install -yq apt-transport-https ca-certificates && \
  sed -i 's/http:/https:/g' /etc/apt/sources.list && \
  apt-get update

RUN apt-get update && \
  apt-get install -yq automake cmake curl g++ gettext git libtool-bin make pkg-config unzip \
  # fix appimagetool: error while loading shared libraries: libgio-2.0.so.0: cannot open shared object file: No such file or directory
  libglib2.0-dev

ARG SOURCE_DIR
ARG BRANCH=master
WORKDIR $SOURCE_DIR
RUN git clone -b ${BRANCH} --single-branch --depth 1 https://github.com/neovim/neovim.git $SOURCE_DIR
COPY nvim-appimage-appimagetool.patch nvim-appimage-appimagetool.patch

ARG CMAKE_BUILD_TYPE=Release
ENV CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
RUN patch -p1 <nvim-appimage-appimagetool.patch && make appimage

FROM scratch
ARG SOURCE_DIR
COPY --from=build ${SOURCE_DIR}/build/bin/nvim.appimage /nvim.appimage
