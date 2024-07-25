#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/fs.h"

//get from ls.c
void
find(char *path,char *name)
{
    char buf[512], *p;
    int fd;
    struct dirent de;
    struct stat st;
    if((fd = open(path, 0)) < 0){
        fprintf(2, "find: cannot open %s\n", path);
        return;
    }

    if(fstat(fd, &st) < 0){
        fprintf(2, "find: cannot stat %s\n", path);
        close(fd);
        return;
    }
    if(strlen(path) + 1 + DIRSIZ + 1 > sizeof buf){
      printf("find: path too long\n");
      return;
    }
    strcpy(buf, path);
    p = buf+strlen(buf);
    *p++ = '/';
    while(read(fd, &de, sizeof(de)) == sizeof(de)){
      if(de.inum == 0)
        continue;
      //prevent 
      if(!strcmp(de.name,".")||!strcmp(de.name,".."))
        continue;
      memmove(p, de.name, DIRSIZ);
      p[DIRSIZ] = 0;
      if(stat(buf, &st) < 0){
        printf("find: cannot stat %s\n", buf);
        continue;
      }
      //check type
      if(st.type==T_DIR)
      {
        find(buf,name);
      }
      else
        //add name comparision
      if(!strcmp(de.name,name))
        printf("%s\n", buf);
    }
    close(fd);
}

int
main(int argc, char *argv[])
{
  if(argc!=3){
    printf("Please watch out your parameters!");
    exit(1);
  }
  find(argv[1],argv[2]);
  exit(0);
}