// $Id:

//
// Copyright 2014-2015 SRC Computers, LLC.  All rights reserved.
//
//      Manufactured in the United States of America.
//
// SRC Computers, LLC
// 4240 N Nevada Avenue
// Colorado Springs, CO 80907
// (v) (719) 262-0213
// (f) (719) 262-0223
//
// As covered under the End User Software License Agreement, no 
// permission has been granted to distribute or copy this software 
// without the express permission of SRC Computers, LLC.
//
// This program is distributed WITHOUT ANY WARRANTY OF ANY KIND.
//
// SRC Computers, LLC Confidential as covered under the NDA agreement.
//

#include <libmap.h>
#include <carte_socket.h>

void subr(int channel, int iflag, int mapnum)
{
    Vec_Stream_64 vs0, vs1;
    In_Chip_Barrier B0;
    In_Chip_Barrier_Set(&B0, 2);


    #pragma src parallel sections
    {
        #pragma src section
        {
            int iii;
            uint8_t ifmask = 0, sin_family = 0;
            uint16_t sin_port = 0;
            uint32_t res=0, sin_addr=0,sockfd=0, connected_sockfd=0, loopcount;

                    carte_getifmask(
                        &ifmask,    //sin_dataif
                        &res );

                    printf("passed carte_getifmask %d\n", res);
                    printf("ifmask = %2x\n", ifmask);

                    carte_getipaddr(
                        channel,                          //data interface #
                        &sin_addr,   //Returned Server Address for dataif
                        &res);
                for(iii=0;iii<1;iii++)
   vdisplay_32 (1, 2000, 1);

                    printf("passed carte_getipadder %d\n", res);
                    printf("%08x\n", sin_addr);
                    printf("%d.%d.%d.%d\n", sin_addr&0xff, (sin_addr>>8)&0xff, (sin_addr>>16)&0xff, (sin_addr>>24)&0xff);

                    carte_socket(
                        channel,              // was 4
                        carte_L4_data_channel_0, //sin_channel
                        CARTE_AF_INET,     //sin_family, IPV4
                        CARTE_SOCK_STREAM, //type, TCP
                        CARTE_IPPROTO_TCP,     //protocol, Socket Protocol
                        &sockfd,
                        &res );
                for(iii=0;iii<1;iii++)
   vdisplay_32 (1, 2001, 1);
                    printf("passed carte_socket %d\n", res);

                    sin_port = 11211;
                    sin_port = htons(sin_port);

                    carte_bind(
                        sockfd,
                        CARTE_AF_INET,  //sin_family, IPV4
                        sin_port,    //sin_port
                        sin_addr, //server IP address
                        &res );
                for(iii=0;iii<1;iii++)
   vdisplay_32 (1, 2002, 1);

                    printf("passed carte_bind %d\n", res);

                carte_listen(
                    sockfd, 
                    1, //backlog socket count?
                    &res );
                printf("past carte_listen %d\n", res);
                for(iii=0;iii<1;iii++)
   vdisplay_32 (1, 2003, 1);

                carte_accept(
                    sockfd,      //listening_sockfd
                    &sin_family, //accepted conn family
                    &sin_port,   //accepted conn port
                    &sin_addr,   //accepted conn IP address
                    &connected_sockfd,
                    &res );
                printf("past carte_accept %d\n", res);
                for(iii=0;iii<1;iii++)
   vdisplay_32 (1, 2004, 1);

            In_Chip_Barrier_Wait(&B0);

            printf("eth_channel_term()\n");
            eth_channel_term(carte_L4_data_channel_0);
            printf("past eth_channel_term()\n");
        }//SECTION

        #pragma src section
        {
            vec_stream_64_from_channel_term( &vs0, carte_L4_data_channel_0 );
            printf("from_stream terminated!\n");
        } 

        #pragma src section
        {
            int32_t iii,first,firstn;
            int64_t val, hdr, tail;
            int32_t count,vec,nv,nrec;
            int32_t i1,i2;
            int16_t j0,j1,j2,j3;
            int8_t  c0,c1,c2,c3,c4,c5,c6,c7;
            int32_t bvec;

            firstn = 1;
            bvec = 0;
            while(is_vec_stream_64_active(&vs0))
            {
                get_vec_stream_64_header(&vs0, &hdr);
                split_64to32 (hdr, &i2,&i1);
                printf("RECV: VEC %i NBYTES %i   HEADER OF VECTOR %016llx\n", bvec,i1,hdr);
                put_vec_stream_64_header(&vs1, hdr);
                bvec++;
                
                nv = i1/8;

          printf ("                           *** record has %i words\n",nv);

                for(iii=0;iii<1;iii++)
                    vdisplay_32(nv, 3003, 1);

                first = 1;
                while(all_vec_streams_active())
                {
                    get_vec_stream_64(&vs0, &val);
                    split_64to8 (val, &c7, &c6, &c5, &c4, &c3, &c2, &c1, &c0);
                    split_64to16 (val, &j3,&j2,&j1,&j0);

                    cg_accum_add_32 (1, 1, -1, (first | c3==0x40), &count);
                    cg_accum_add_32 (1, c3==0x40, -1, firstn, &vec);
                    firstn = 0;
                    first  = 0;
    

// printf ("count %i val in %016llx\n",count,val);
//   printf ("count %i vec %i\n",count,vec);

//                  nrec = nv/i1;
//                  if (c3 == 0x40) { printf ("*** header  nrec %i in packet\n",nrec); }


                    if (count>0) {
                       val = val + 0x100000;
                       if (iflag)
                          val = val + vec*0x1000000;
// printf ("af add   val     %016llx\n",val);
                    }

  
//                  vdisplay_32(nrec, 3012, c3==0x40);
//                    vdisplay_64(val, 3013, 1);
                    put_vec_stream_64(&vs1, val, 1);
                }

                get_vec_stream_64_tail(&vs0, &tail);
                printf("RECV: END OF VECTOR %016llx\n", tail);
                put_vec_stream_64_tail(&vs1, tail);
 //               for(iii=0;iii<1;iii++)
 //                   vdisplay_64(tail, 3020, 1);

                //EXIT CONDITION WHEN CLIENT CLOSES THE VECTOR
                if(tail == CARTE_CLOSE_STATE_VECTOR_IDENT)
                {
                    printf("RECEIVED CLOSE STATE VECTOR!\n");
                    In_Chip_Barrier_Wait(&B0);
                }
            }
              
            vec_stream_64_term(&vs1);
            printf("vec_stream vs1 terminated!\n");
        }//END

        #pragma src section
        {
            vec_stream_64_to_channel_term( &vs1, carte_L4_data_channel_0 );
            printf("to_stream terminated!\n");
        }

    }//END REGION
}//END SUBR()
