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

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


Name:           yast2-fonts
Version:        3.1.0
Release:        0
BuildArch:      noarch

BuildRoot:      %{_tmppath}/%{name}-%{version}-build
Source0:        %{name}-%{version}.tar.bz2

Requires:       yast2 >= 3.0.5
Requires:       yast2-ruby-bindings >= 1.2.0
Requires:       fonts-config
Requires:       fontconfig

BuildRequires:  update-desktop-files
BuildRequires:  yast2-ruby-bindings >= 1.2.0
BuildRequires:  yast2-devtools >= 1.2.0
BuildRequires:  yast2 >= 3.0.5
BuildRequires:  rubygem-yast-rake

Summary:        YaST2 - Fonts Configuration
Group:          System/YaST
License:        GPL-2.0+
Url:            https://github.com/yast/yast-fonts

%description
Module for configuring X11 fonts able to select prefered font families
as well as set rendering algorithms to be used.


%prep
%setup -n %{name}-%{version}

%install
rake install DESTDIR="%{buildroot}"

%files
%defattr(-,root,root)
%dir %{yast_libdir}/fonts
%{yast_libdir}/fonts/*.rb
%{yast_clientdir}/fonts.rb
%{yast_desktopdir}/fonts.desktop
%{yast_scrconfdir}/*.scr
%dir %{yast_docdir}
%doc %{yast_docdir}/CONTRIBUTING.md
%doc %{yast_docdir}/COPYING

%changelog
