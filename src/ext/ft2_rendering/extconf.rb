require 'mkmf'

extension_name = 'ft2_rendering'

$LDFLAGS << ' ' + `pkg-config --libs freetype2`
$CFLAGS << ' ' + `pkg-config --cflags freetype2`

dir_config(extension_name)
create_makefile(extension_name)

