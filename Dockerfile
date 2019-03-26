FROM yastdevel/ruby:sle15-sp1
RUN zypper --gpg-auto-import-keys --non-interactive in --no-recommends \
  dejavu-fonts \
  font-specimen-devel \
  fontconfig-devel \
  fonts-config \
  freetype2-devel \
  ruby-devel
COPY . /usr/src/app

