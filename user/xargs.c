#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/param.h"
#include "user/user.h"

int
main(int argc, char *argv[])
{
    if(argc <2){
        printf("Please change your parameter numbers!");
        exit(1);
    }
    int p[2];
    char s;
    char *newargv[MAXARG];
    pipe(p);
    if(fork()==0){
        int i=0,j=1;
        close(p[1]);
        newargv[0]=malloc(32);
        newargv[1]=malloc(32);
        int t;
        //get
        while(read(p[0],&t,1)!=0){
            if(t!='\n'){
                newargv[j][i++]=t;
            }
            else{
                newargv[j][i]='\0';
                j++;
                newargv[j]=malloc(32);
                i=0;
            }
        }
        exec(argv[1],newargv);
        free(newargv);
        close(p[0]);
    }else{
        close(p[0]);
        //write
        for(int i=2;i<argc;i++){
            write(p[1],argv[i],strlen(argv[i]));
            write(p[1],"\n",1);
        }
        //write
        while(read(0,&s,1)!=0){
            if(s==' ')
                write(p[1],"\n",1);
            else
                write(p[1],&s,1);
        }
        write(p[1],"\n",1);
        close(p[1]);
        wait(0);
    }
    exit(0);
}