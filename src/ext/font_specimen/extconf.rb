# encoding: utf-8
#

require 'mkmf'

$LDFLAGS << ' -lfont-specimen'

extension_name = 'font_specimen'

dir_config(extension_name)
create_makefile(extension_name)

