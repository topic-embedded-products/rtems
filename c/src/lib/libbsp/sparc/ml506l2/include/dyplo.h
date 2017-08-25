/*
 * DYPLO configuration
 * COPYRIGHT (c) 2017.
 * Topic Embedded Products
 */

#ifndef __BSP_DYPLO_H
#define __BSP_DYPLO_H

#define BSP_DYPLO_BASE_ADDR 0xD0000000

// Note: by default Dyplo uses IRQ 5. The source (PIO pin) of this interrupt
// needs to be configured as well in bspstart.c when using on LEON2 or LEON2FT. 
#define BSP_DYPLO_IRQ 5

#endif
