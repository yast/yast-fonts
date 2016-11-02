# encoding: utf-8
#

require 'mkmf'

extension_name = 'fontconfig_setting'

$LDFLAGS << ' ' + `pkg-config --libs fontconfig`
# there is bug in fontconfig.pc (will fix soon ;)
$CFLAGS << ' ' + ' -I/usr/include/fontconfig ' + `pkg-config --cflags fontconfig`

dir_config(extension_name)
create_makefile(extension_name)

