#include "kernel/types.h"
#include "kernel/riscv.h"
#include "kernel/sysinfo.h"
#include "user/user.h"
int 
main(int argc,char*argv[]){
    if(argc!=1)
    {
        printf("sysinfo:Failed");
        exit(1);
    }
    struct sysinfo inf;
    sysinfo(&inf);
    printf("free space: %d\nused process: %d\n",inf.freemem,inf.nproc);
    exit(0);
}