/**
 * Code to solve KDV equations by finite diferences
 * @autor Rafael Lima
 * @version 0.1
 */

#define DIFF 0.0001 /**< mensure to deal derivate limits**/

/**
 * @defgroup diffFinite Finite Diferences Aproximations
 */


/**
 * First Derivate in t of u(t1,x1)
 * @ingroup diffFinite
 * @param ul1 
 * @param ur1
 * @param dt 
 */
float Ut(float ul1,float ur1,float dt);

/**
 * First Derivate in x of u(t,x)
 * @ingroup diffFinite
 * @param u_l1 A point left the point
 * @param u_r1 A point right the point
 * @param dx Variation on x
 */
float Ux(float u_l1, float u_r1,float dx);

/**
 * Third Derivate in x of u(t,x)
 * @ingroup diffFinite
 * @param u_l2 A point 2 points to left
 * @param u_l1 A point 1 point to left
 * @param u_r1 A point 1 point to right
 * @param u_r2 A point 2 point to right
 */
float Uxxx(float u_l2,float u_l1,float u_r1,float u_r2,float dx);

/**
 * Calculate next u(x,t2)
 * @ingroup diffFinite
 */
float KDVstep(float u_l2,float u_l1,float u_r1,float u_r2,float dx,float dt,float C, float K);

float f0(float x);

float loopVector(float *u0,int length, int pos);

float KDVstepLoop(float *u0,int length,float dx,float dt,float C,float K);
