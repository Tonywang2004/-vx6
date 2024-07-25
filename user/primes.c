#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"

void getnewprime(int p){
    //represent prime and data. 
    int current,nex;
    read(p,&current,sizeof(current));
    printf("prime %d\n",current);
    int i=0;
    int sec[2];
    while(read(p,&nex,sizeof(nex))){
        if(i==0){
            pipe(sec);
            //fork only once
            i=1;
            if(fork()==0){
                close(sec[1]);
                getnewprime(sec[0]);
                exit(0);
            }
        }
        if(nex%current!=0)
            write(sec[1],&nex,sizeof(nex));
    }
    close(sec[1]);
    wait(0);
}


int main(int argc, char *argv[])
{
    
    //create pipeline
    int fir[2];
    pipe(fir);
    if(fork()>0){
        //write all number 
        //init
        close(fir[0]);
        for(int i=2;i<=35;i++)
            write(fir[1],&i,sizeof(int));
        close(fir[1]);
        wait(0);
    }
    else{
        close(fir[1]);
        getnewprime(fir[0]);
    }
    exit(0);
}


