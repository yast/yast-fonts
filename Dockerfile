FROM yastdevel/ruby:sle12-sp3
RUN zypper --gpg-auto-import-keys --non-interactive in --no-recommends \
  dejavu-fonts \
  font-specimen-devel \
  fontconfig-devel \
  fonts-config \
  freetype2-devel \
  ruby-devel
COPY . /usr/src/app

