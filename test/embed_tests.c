/* vProlog embedded C-API test: proves the engine runs core+CLP+CJK+DCG
   through pl_create/pl_consult/pl_query (the path the R package uses). */
#include <stdio.h>
#include "trealla.h"
extern char **environ;
char **g_envp = NULL;
void sigfn(int s) { (void)s; }

int main(void){
  g_envp = environ;
  prolog *pl = pl_create();
  if(!pl){ printf("FAIL: pl_create\n"); return 2; }
  if(!pl_consult(pl, "test/suite/embed_checks.pl")){
    printf("FAIL: pl_consult embed_checks.pl\n"); pl_destroy(pl); return 2; }
  pl_sub_query *q = NULL;
  bool ok = pl_query(pl, "embed_all", &q, 0);
  if(q) pl_done(q);
  printf("embed C-API (core+CLP(Z)+CLP(B)+CJK+DCG): %s\n", ok ? "PASS" : "FAIL");
  pl_destroy(pl);
  return ok ? 0 : 1;
}
