#include <stdio.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
  FILE *fp;
  unsigned char c;
  int i;
  int useThisOne = 0;
  if(argc < 2)
  {
    printf("usage %s filename\n", argv[0]);
    exit(-1);
  }
  fp = fopen(argv[1], "rt");
  if(fp == NULL)
  {
    printf("file \"%s\" does not exist\n", argv[1]);
    exit(-1);
  }

  c = fgetc(fp);
  if(c != 0xff)
    printf("%c", c);
  c = fgetc(fp);
  if(c != 0xfe)
    printf("%c", c);
  while(!feof(fp))
  {
    c = fgetc(fp);
    if((useThisOne = !useThisOne))
    {
      if(!feof(fp))
        printf("%c", c);
    }
  }
  return(0);
}