#include "ruby.h"
#include <fontconfig.h>
#include <string.h>
#include <stdio.h>

const char *blacklist_families[] = {
      "micro.pcf",
      "deccurs.pcf",
      "decsess.pcf",
      "cursor.pcf",
    };

#define NBLACK (sizeof(blacklist_families)/sizeof(blacklist_families[0]))

VALUE FontconfigSetting = Qnil;

void Init_fontconfig_setting();
VALUE method_fc_installed_families(VALUE self, VALUE array_elements);
VALUE method_fc_is_family_installed(VALUE self, VALUE str_family);

void Init_fontconfig_setting() {
  FontconfigSetting = rb_define_module("FontconfigSetting");
  rb_define_method(FontconfigSetting, "fc_installed_families", 
                   method_fc_installed_families, 1);
  rb_define_method(FontconfigSetting, "fc_is_family_installed", 
                   method_fc_is_family_installed, 1);
}

VALUE method_fc_installed_families(VALUE self, VALUE array_elements) {
  VALUE str_family_list = rb_ary_new();

  FcObjectSet *objectset;
  FcFontSet *fontset;
  FcPattern *empty;

  char *str_pattern;
  int i, j;
  VALUE el;

  FcInit();
  objectset = FcObjectSetCreate();
  while ((el = rb_ary_shift(array_elements)) != Qnil)
  {
    FcObjectSetAdd(objectset, StringValueCStr(el));
  }
  empty = FcPatternCreate();
  fontset = FcFontList (NULL, empty, objectset);
  FcObjectSetDestroy (objectset);
  FcPatternDestroy(empty);

  for (i = 0; i < fontset->nfont; i++) 
  {    
    str_pattern = (char *)FcPatternFormat(fontset->fonts[i], (const FcChar8 *)"%{=fclist}");
    for (j = 0; j < NBLACK; j++)
      if (strcmp(blacklist_families[j], str_pattern) == 0)
        break;
    if (j < NBLACK)
      continue;
    rb_ary_push(str_family_list, rb_str_new2(str_pattern));
  }

  return str_family_list;
}

VALUE method_fc_is_family_installed(VALUE self, VALUE str_family) {
  FcObjectSet *objectset;
  FcPattern *pattern;
  FcFontSet *fontset;

  char *family;

  family = StringValueCStr(str_family);

  FcInit();
  objectset = FcObjectSetBuild(FC_FAMILY, NULL);
  pattern = FcNameParse((FcChar8 *)family);
  fontset = FcFontList (NULL, pattern, objectset);
  FcPatternDestroy (pattern);
  FcObjectSetDestroy (objectset);

  if (fontset->nfont > 0)
    return Qtrue;
  else
    return Qfalse;
}

