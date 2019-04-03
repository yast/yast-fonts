FROM registry.opensuse.org/yast/head/containers/yast-ruby:latest
RUN zypper --gpg-auto-import-keys --non-interactive in --no-recommends \
  dejavu-fonts \
  font-specimen-devel \
  fontconfig-devel \
  fonts-config \
  freetype2-devel \
  ruby-devel
COPY . /usr/src/app

