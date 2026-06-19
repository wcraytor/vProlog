#include <stdio.h>
#include "trealla.h"
extern char **environ;
char **g_envp = NULL;
void sigfn(int s) { (void)s; }
int main(void){
  prolog *pl = pl_create();
  if(!pl){ printf("pl_create failed\n"); return 1; }
  g_envp = environ;
  bool ok = pl_consult(pl, "/Volumes/Nvme_1/ClaudeCode/vProlog/test/clp_embed.pl");
  printf("[C driver] pl_consult -> %s\n", ok ? "true" : "false");
  pl_destroy(pl);
  return ok ? 0 : 1;
}
