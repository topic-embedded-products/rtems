/**
 * @file
 * @ingroup sparc_leon2
 * @brief LEON2 Cache Snooping Support
 */

/*
 *  LEON2 Cache Snooping Support
 *
 *
 *  COPYRIGHT (c) 1989-2009.
 *  On-Line Applications Research Corporation (OAR).
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.rtems.org/license/LICENSE.
 *
 *  Ported to ERC32 implementation of the SPARC by On-Line Applications
 *  Research Corporation (OAR) under contract to the European Space
 *  Agency (ESA).
 *
 *  ERC32 modifications of respective RTEMS file: COPYRIGHT (c) 1995.
 *  European Space Agency.
 */

#include <bsp.h>
#include <bsp/bootcard.h>

/*
 * Tells us if data cache snooping is available
 */
int CPU_SPARC_HAS_SNOOPING;

/*
 * set_snooping
 *
 * Read the data cache configuration register to determine if
 * bus snooping is available. This is needed for some drivers so
 * that they can select the most efficient copy routines.
 */
static inline int set_snooping(void)
{
  unsigned int tmp = *(unsigned int *)0x80000014; /* Cache control register */
  return ((tmp>>23) & 1); /* Data cache snooping enabled */
}

/* Coherent memory region. There's 512MB RAM, mapped to 0x40000000 in the
 * CPU cacheable region. It's also mapped into 0xA0000000 without cache.
 * Use a portion of the RAM as coherent buffer by only accessing it through
 * the non-cachable range */
static const void* bsp_nocache_heap_begin	= 0xB0000000;
static const uintptr_t bsp_nocache_heap_size	= 0x08000000;

void bsp_start( void )
{
  CPU_SPARC_HAS_SNOOPING = set_snooping();
  
  rtems_cache_coherent_add_area(bsp_nocache_heap_begin, bsp_nocache_heap_size);
}
