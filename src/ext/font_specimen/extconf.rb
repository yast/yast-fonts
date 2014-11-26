require 'mkmf'

$LDFLAGS << ' -lfont-specimen -lfontconfig -lfreetype -lpng -lharfbuzz'

extension_name = 'font_specimen'

dir_config(extension_name)
create_makefile(extension_name)

