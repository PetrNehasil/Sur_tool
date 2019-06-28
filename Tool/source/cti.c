#include <unistd.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>


#define FIFO "/tmp/p1"
 
 
void consumer(int id) {
    ssize_t readed;
    char ch[1023];
    do {
        readed = read(id,&ch,1024);
        //if(readed != sizeof(i)) break;
        if(readed != 0)
         {
           ch[readed]=0x00;
           //printf("Prislo %i ",(int)readed);
           //printf("Obsah %s\n",ch);
           printf("%s\n",ch);
         }
         sleep(1);
    } while(true);
    close(id);
}
 
int main(void) {
    pid_t pid;
    int fd;
   
    if((fd=open(FIFO,O_RDONLY)) == -1) {
        perror("open file");
        exit(1);
    }

    consumer(fd);

    return 0;
}
