/*
 *  ptimer.c,v 1.1 1996/06/03 16:29:58 joel Exp
 */
 
#include <assert.h>
#include <time.h>
#include <errno.h>

#include <rtems/system.h>
#include <rtems/score/isr.h>
#include <rtems/score/thread.h>
#include <rtems/score/tod.h>

#include <rtems/posix/time.h>

/************************************/
/* These includes are now necessary */
/************************************/

#include <sys/features.h>
#include <rtems/rtems/status.h>
#include <rtems/rtems/types.h>
#include <rtems/rtems/timer.h>
#include <rtems/rtems/clock.h>
#include <rtems/posix/psignal.h>
#include <rtems/score/wkspace.h>
#include <pthread.h>
#include <stdio.h>
#include <signal.h>

/*****************************/
/* End of necessary includes */
/*****************************/

#include <rtems/posix/timer.h>

/* ***************************************************************************
 * _POSIX_Timer_Manager_initialization
 *
 *  Description: Initialize the internal structure in which the data of all 
 *               the timers are stored
 * ***************************************************************************/

extern void TIMER_INITIALIZE_S( int );
int timer_max;
timer_alive_t *timer_struct;


void _POSIX_Timer_Manager_initialization ( int max_timers )
{
   int index;

   timer_struct = _Workspace_Allocate_or_fatal_error(
      max_timers * sizeof(timer_alive_t) );

   /* 
    *  Initialize all the timers
    */

   timer_max = max_timers;

   for (index=0; index<max_timers; index++)
     TIMER_INITIALIZE_S( index );

   timer_max = max_timers;
}

