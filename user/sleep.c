#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/param.h"
//sleep.c
int
main(int argc, char *argv[]){
    //check argc
    if(argc!=2){
        printf("Please change your parameter numbers!");
        exit(1);
    }
    else{
        sleep(atoi(argv[1]));
    }
    exit(0);
}