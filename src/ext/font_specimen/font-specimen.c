#include <ruby.h>
#include <ruby/io.h>
#include <font-specimen.h>

#define MAX_SCRIPTS 20

VALUE FontSpecimen = Qnil;

void Init_font_specimen();
VALUE method_font_scripts(VALUE self, VALUE str_pattern);
VALUE method_specimen_write(VALUE self,
                            VALUE str_pattern,
                            VALUE str_script,
                            VALUE int_png_fd,
                            VALUE int_width,
                            VALUE int_height);

void Init_font_specimen() {
  FontSpecimen = rb_define_module("FontSpecimen");
  rb_define_method(FontSpecimen, "font_scripts", 
                   method_font_scripts, 1);
  rb_define_method(FontSpecimen, "specimen_write", 
                   method_specimen_write, 5);
}

VALUE method_font_scripts(VALUE self, VALUE str_pattern) {
  VALUE res_hash = rb_hash_new();

  char *pattern;
  const char *scripts[MAX_SCRIPTS];
  double coverages[MAX_SCRIPTS];
  char str_coverage[6];

  int s, nscripts;

  pattern = StringValueCStr(str_pattern);

  if ((nscripts = specimen_font_scripts(pattern, SCRIPT_SORT_PERCENT,
                                        scripts, coverages, MAX_SCRIPTS)) <= 0)
    return res_hash;

  for (s = 0; s < nscripts; s++)
  {
    snprintf(str_coverage, 6, "%.1f", coverages[s]);
    rb_hash_aset(res_hash, 
                 rb_str_new2(scripts[s]), rb_str_new2(str_coverage));
  }

  return res_hash;
}

VALUE method_specimen_write(VALUE self,
                            VALUE str_pattern,
                            VALUE str_script,
                            VALUE png_file,
                            VALUE int_width,
                            VALUE int_height) 
{
  char *pattern = StringValueCStr(str_pattern);
  char *script  = StringValueCStr(str_script);
  rb_io_t *fptr = RFILE(png_file)->fptr;
  int png_fd    = fptr->fd;
  int width     = NUM2INT(int_width);
  int height    = NUM2INT(int_height);

  FILE *png = NULL;

  png = rb_fdopen(png_fd, "w");
  if (!png)
    return Qfalse;

  if (specimen_write(SPECIMEN_COMPACT, pattern, script, png, width, height))
    return Qfalse;

  fflush(png);

  return Qtrue;
}

