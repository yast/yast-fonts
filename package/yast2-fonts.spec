#
# spec file for package yast2-fonts
#
# Copyright (c) 2014 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via https://bugs.opensuse.org/
#


Name:           yast2-fonts
Version:        4.1.0
Release:        0
Summary:        YaST2 - Fonts Configuration
Group:          System/YaST
License:        GPL-2.0+
Url:            https://github.com/yast/yast-fonts

Source0:        %{name}-%{version}.tar.bz2

BuildRequires:  update-desktop-files
BuildRequires:  yast2-ruby-bindings >= 1.2.0
BuildRequires:  yast2-devtools >= 1.2.0
BuildRequires:  yast2 >= 3.0.5
BuildRequires:  rubygem(yast-rake)
# extensions
BuildRequires:  freetype2-devel
BuildRequires:  fontconfig-devel
BuildRequires:  font-specimen-devel
BuildRequires:  ruby-devel
# for testing
BuildRequires:  rubygem(rspec)
BuildRequires:  dejavu-fonts
BuildRequires:  fonts-config >= 20150424

Requires:       yast2 >= 3.0.5
Requires:       yast2-ruby-bindings >= 1.2.0
Requires:       fonts-config >= 20150424
Requires:       fontconfig

%description
Module for configuring X11 fonts able to select preferred font families
as well as set rendering algorithms to be used.

%prep
%setup -q

%build
# build ruby bindings
rake compile

%install
%yast_install
# install ruby bindings
mkdir -p  %{buildroot}%{rb_vendorarchdir}/yast
for ext in `ls src/ext`; do
  install -m 755 src/ext/$ext/$ext.so %{buildroot}%{rb_vendorarchdir}/yast
done
%yast_metainfo

%check
%yast_check

%files
%{yast_libdir}
%{rb_vendorarchdir}/yast/*.so
%{yast_clientdir}
%{yast_desktopdir}
%{yast_metainfodir}
%{yast_scrconfdir}
%doc %{yast_docdir}
%license COPYING
%{yast_icondir}

%changelog
