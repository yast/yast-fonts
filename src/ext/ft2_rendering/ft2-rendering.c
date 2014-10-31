#include "ruby.h"
#include <ft2build.h>
#include FT_LCD_FILTER_H

VALUE Ft2Rendering = Qnil;

void Init_ft2_rendering();
VALUE method_ft2_have_freetype(VALUE self);
VALUE method_ft2_have_subpixel_rendering(VALUE self);

void Init_ft2_rendering() {
  Ft2Rendering = rb_define_module("Ft2Rendering");
  rb_define_method(Ft2Rendering, "have_freetype", 
                   method_ft2_have_freetype, 0);
  rb_define_method(Ft2Rendering, "have_subpixel_rendering", 
                   method_ft2_have_subpixel_rendering, 0);
}

VALUE method_ft2_have_freetype(VALUE self) {
  FT_Library library;
  FT_Error error;

  error = FT_Init_FreeType(&library);
  FT_Done_FreeType(library);

  if (error)
    return Qfalse;
  return Qtrue;
}

VALUE method_ft2_have_subpixel_rendering(VALUE self) {
  FT_Library library;
  FT_Error error;

  error = FT_Init_FreeType(&library);
  if (error)
    return Qfalse;

  /* returns FT_Err_Unimplemented_Feature when subpixel rendering
     support is compiled in */
  error = FT_Library_SetLcdFilter(library, FT_LCD_FILTER_NONE);
  FT_Done_FreeType(library);

  if (error)
    return Qfalse;
  return Qtrue;
}

