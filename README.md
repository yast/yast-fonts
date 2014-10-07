yast-fonts
==========

This YaST module brings a layer over fontconfig settings to control
font appearance on the system in two aspects: 
* font rendering algorithm type,
* font family preference.

The main mission is to bring font rendering options closer 
to user. It is intended to weaken term 'default font setting'.

Note: this module expect recent changes to fontconfig 
and fonts-config package. It will not work with
respective openSUSE:13.1 packages. You can install new
versions of packages from M17N repository though.

