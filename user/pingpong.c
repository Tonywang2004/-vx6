#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    //pingpong.c
    //1:write,0:read
    int fir[2],sec[2];
    //create pipelines
    pipe(fir);
    pipe(sec);
    char data[20];
    if(fork()==0){
    //child
    //getpid() get pid
        read(fir[0],data,4);
        printf("%d: received %s\n",getpid(),data);
        write(sec[1],"pong",strlen("pong"));
    }
    else{
        //parent
        write(fir[1],"ping",strlen("ping"));
        wait(0);
        read(sec[0],data,4);
        printf("%d: received %s\n",getpid(),data);
    }
    exit(0);
}