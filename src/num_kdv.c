/**
 * @headerfile num_kdv.h
 */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include "num_kdv.h"

#define RANGE 100

int main(){
  FILE *fpi,*fpo;

  //  fpi = fopen("ini.dat","r");
  fpo = fopen("kdv.dat","w");

  //f(x):
  float u0[RANGE], u1[RANGE];
  float dx = 0.01
  int i,j;
  for(i=0;i<RANGE;i++){
    ///TODO write file output
    u0[i] = f0(i*dx);
    fprintf(fpo,"%f\t%f\t%f\n",i*dx,0.0,u0[i]);
  }

  //c , K:
  float c = 1 , K=1 , dt = 0.1;

  for(j=1;j<3;j++){
    for(i=0;i<RANGE;i++){
      u1[i]=KDVstepLoop(u0,RANGE,dx,dt,c,K);
    }
    for(i=0;i<RANGE;i++){
      fprintf(fpo,"%f\t%f\t%f\n",i*dx,j*dt,u1[i]);
      u0[i]=u1[i];
    }
  }
}

float loopVector(float *u0,int length, int pos){
  return(u0[(length+pos)%length]);
}

float f0(float x){
  if(x>(RANGE/10))
    return 1;
  else
    return 0;
}

/* u_l2 , u_l1 , u , u_r1 , u_r2 */

float Ux(float u_l1,float u_r1,float dx){
  return ((u_r1-u_l1)/(2*dx));
}

float Uxxx(float u_l2,float u_l1,float u_r1,float u_r2,float dx){
  float uxxx = ((0.5)*u_l2 + u_l1 - u_r1 + (0.5)*u_r2)/(dx*dx*dx);
  return uxxx;
}

float KDVstep(float u_l2,float u_l1,float u_r1,float u_r2,float dx,float dt,float C, float K){
  float u1 = -(C*dt)*Ux(u_l1,u_r1,dx) - K*dt*Uxxx(u_l2,u_l1,u_r1,u_r2,dx);
  return u1;
}

float KDVstepLoop(float *u0,int length,float dx,float dt,float C,float K){
  float u1 = KDVstep(loopVector(u0,length,-2),
		     loopVector(u0,length,-1),
                     loopVector(u0,length,1),  
                     loopVector(u0,length,2),
		     dx,dt,C,K);
  return u1;
}
