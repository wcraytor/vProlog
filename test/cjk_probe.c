#include <stdio.h>
#include "trealla.h"
extern char **environ; char **g_envp=NULL; void sigfn(int s){(void)s;}
int main(void){ prolog *pl=pl_create(); if(!pl)return 1; g_envp=environ;
  bool ok=pl_consult(pl,"/tmp/cjk.pl");
  printf("[C driver] CJK consult -> %s\n", ok?"true":"false"); pl_destroy(pl); return ok?0:1; }
