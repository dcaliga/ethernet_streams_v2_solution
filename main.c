static char const cvsid[] = "$Id: main.c,v 2.1 2005/06/14 22:16:50 jls Exp $";

/*
 * Copyright 2005 SRC Computers, Inc.  All Rights Reserved.
 *
 *	Manufactured in the United States of America.
 *
 * SRC Computers, Inc.
 * 4240 N Nevada Avenue
 * Colorado Springs, CO 80907
 * (v) (719) 262-0213
 * (f) (719) 262-0223
 *
 * No permission has been granted to distribute this software
 * without the express permission of SRC Computers, Inc.
 *
 * This program is distributed WITHOUT ANY WARRANTY OF ANY KIND.
 */

#include <libmap.h>
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

#define MAXVECS 1024 
#define MAXVEC_LEN 1024 

void subr (int channel, int iflag, int mapnum);

int main (int argc, char *argv[]) {
    FILE *res_map, *res_cpu;
    int i, maxlen,nvec;
    int64_t *A64, *B64, *Counts;
    int32_t *A32;
    int16_t *A16;
    int64_t tm,i64;
    int total_nsamp,ij,cnt,j,channel,iflag;
    int mapnum = 0;
    int32_t i32;
    char c;

    if ((res_map = fopen ("res_map", "w")) == NULL) {
        fprintf (stderr, "failed to open file 'res_map'\n");
        exit (1);
        }

    if ((res_cpu = fopen ("res_cpu", "w")) == NULL) {
        fprintf (stderr, "failed to open file 'res_cpu'\n");
        exit (1);
        }

    channel = 3;
    nvec = 0;
    iflag = 0;

    while ((c = getopt(argc, argv,
        "c:fh")) != EOF) {
        switch (c) {
    case  'c':
        channel = atoi(optarg);
        printf("MAP ethernet channel         %6i  \n",channel);
        break;
    case  'f':
        iflag = 1;
        printf("Output data has the vector number added \n");
        break;
    case 'h':
    default:
        printf("-n Number of vectors                \n");
        printf("-m MAP channel          Default is 3\n");
        printf("-f Output data has the vector number added \n");
        exit (0);
    }
    }

  printf ("**** Summary ****\n");
  printf ("MAP channel              %d\n",channel);
  if (iflag)
        printf("Output data has the vector number added \n");



    map_allocate (1);

    // call the MAP routine
    subr (channel, iflag, mapnum);

//    printf ("compute on MAP: %10lld clocks\n", tm);


    map_free (1);

    exit(0);
    }
