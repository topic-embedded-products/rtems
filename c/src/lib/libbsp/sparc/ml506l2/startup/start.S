/**
 *  Common start code for ML506.
 *
 *  This is a copy of the generic sparc start.S with addition of the memory
 *  controller init which is needed to make things boot from PROM.
 *
 *  The license and distribution terms for this file may be
 *  found in the file LICENSE in this distribution or at
 *  http://www.rtems.org/license/LICENSE.
 */

#include <rtems/asm.h>
#include <rtems/score/percpu.h>
#include <bspopts.h>

/* Settings for this particular system. Should come from BSP include file. */
#define LEON2_MCFG1_VALUE	0x101
#define LEON2_MCFG2_VALUE	0xe60
#define UART1_SCALER_VALUE	0x999
#define UART1_CONTROL_VALUE	0x3
#define TIMER_COUNTER_VALUE	0xDEAFBABE
#define TIMER_CONTROL_VALUE	0x7

#define LEON2_CLOCK_SPEED	10
#define LEON2_RDB_START		(SYM(RAM_END) - 64)

/*
 *  Unexpected trap will halt the processor by forcing it to error state
 */
#define BAD_TRAP \
  ta 0; \
  nop; \
  nop; \
  nop;

/*
 * System call optimized trap table entry
 */
#define IRQDIS_TRAP(_handler)  \
  mov   %psr, %l0 ; \
  sethi %hi(_handler), %l4 ; \
  jmp   %l4+%lo(_handler); \
   or   %l0, 0x0f00, %l3; ! Set PIL=0xf to disable IRQ

/*
 * System call optimized trap table entry
 */
#define IRQEN_TRAP(_handler)  \
  mov   %psr, %l0 ; \
  sethi %hi(_handler), %l4 ; \
  jmp   %l4+%lo(_handler); \
   andn %l0, 0xf00, %l3; ! Set PIL=0 to Enable IRQ

/*
 * Window Overflow optimized trap table entry
 */
#define WOTRAP(_vector, _handler)  \
  sethi %hi(_handler), %l4; \
  jmp   %l4+%lo(_handler); \
    save; \
  nop

/*
 * Window Underflow optimized trap table entry
 */
#define WUTRAP(_vector, _handler)  \
  mov   %wim, %l3 ; \
  sethi %hi(_handler), %l4 ; \
  jmp   %l4+%lo(_handler); \
   sll  %l3, 1, %l4 ! l4 = WIM << 1

/*
 *  Software trap. Treat as BAD_TRAP for the time being...
 */

#define SOFT_TRAP BAD_TRAP

/*
 * The trap table occupies the first part of the data segment, which will be
 * at the start of RAM.
 */

.seg    "data"

  PUBLIC(trap_table)
SYM(trap_table):

  RTRAP( 0, SYM(hard_reset) );                  ! 00 reset trap
  BAD_TRAP;                                     ! 01 instruction access
                                                !    exception
  BAD_TRAP;                                     ! 02 illegal instruction
  BAD_TRAP;                                     ! 03 privileged instruction
  BAD_TRAP;                                     ! 04 fp disabled
  WOTRAP(5, SYM(window_overflow_trap_handler)); ! 05 window overflow
  WUTRAP(6, SYM(window_underflow_trap_handler));! 06 window underflow
  BAD_TRAP;                                     ! 07 memory address not aligned
  BAD_TRAP;                                     ! 08 fp exception
  BAD_TRAP;                                     ! 09 data access exception
  BAD_TRAP;                                     ! 0A tag overflow
  BAD_TRAP;                                     ! 0B undefined
  BAD_TRAP;                                     ! 0C undefined
  BAD_TRAP;                                     ! 0D undefined
  BAD_TRAP;                                     ! 0E undefined
  BAD_TRAP;                                     ! 0F undefined
  BAD_TRAP;                                     ! 10 undefined

  /*
   *  ERC32 defined traps
   */

  BAD_TRAP;                                     ! 11 masked errors
  BAD_TRAP;                                     ! 12 external 1
  BAD_TRAP;                                     ! 13 external 2
  BAD_TRAP;                                     ! 14 UART A RX/TX
  BAD_TRAP;                                     ! 15 UART B RX/TX
  BAD_TRAP;                                     ! 16 correctable memory error
  BAD_TRAP;                                     ! 17 UART error
  BAD_TRAP;                                     ! 18 DMA access error
  BAD_TRAP;                                     ! 19 DMA timeout
  BAD_TRAP;                                     ! 1A external 3
  BAD_TRAP;                                     ! 1B external 4
  BAD_TRAP;                                     ! 1C general purpose timer
  BAD_TRAP;                                     ! 1D real time clock
  BAD_TRAP;                                     ! 1E external 5
  BAD_TRAP;                                     ! 1F watchdog timeout

  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 20 - 23 undefined
  BAD_TRAP;                                     ! 24 cp_disabled
            BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 25 - 27 undefined
  BAD_TRAP;                                     ! 28 cp_exception
            BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 29 - 2B undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 2C - 2F undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 30 - 33 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 34 - 37 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 38 - 3B undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 3C - 3F undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 40 - 43 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 44 - 47 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 48 - 4B undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 4C - 4F undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 50 - 53 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 54 - 57 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 58 - 5B undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 5C - 5F undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 60 - 63 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 64 - 67 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 68 - 6B undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 6C - 6F undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 70 - 73 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 74 - 77 undefined
  BAD_TRAP; BAD_TRAP; BAD_TRAP; BAD_TRAP;       ! 78 - 7B undefined

/*
   This is a sad patch to make sure that we know where the
   MEC timer control register mirror is so we can stop the timers
   from an external debugger. It is needed because the control
   register is write-only. Trap 0x7C cannot occure in ERC32...

   We also use this location to store the last location of the
   usable RAM in order not to overwrite the remote debugger with
   the RTEMS work-space area.

*/

	.global SYM(_ERC32_MEC_Timer_Control_Mirror), SYM(rdb_start), SYM(CLOCK_SPEED)

SYM(rdb_start):
SYM(_ERC32_MEC_Timer_Control_Mirror):

  .word LEON2_RDB_START, 0, 0, 0	! 7C End of RAM marker (rdb_start)
  BAD_TRAP;                             ! 7D undefined

SYM(CLOCK_SPEED):

  .word	LEON2_CLOCK_SPEED, 0, 0, 0	! 7E (10 MHz default)

  BAD_TRAP; 					! 7F undefined

  /*
   *  Software traps
   *
   *  NOTE: At the risk of being redundant... this is not a full
   *        table.  The setjmp on the SPARC requires a window flush trap
   *        handler and RTEMS will preserve the entries that were
   *        installed before.
   */

  TRAP( 0x80, SYM(syscall) );                   ! 80 halt syscall SW trap
  SOFT_TRAP; SOFT_TRAP;                         ! 81 - 82
  TRAP( 0x83, SYM(window_flush_trap_handler) ); ! 83 flush windows SW trap

  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! 84 - 87
  SOFT_TRAP;                                    ! 88

  /*
   *  SW Trap 9-15 Reserved for Operating System
   *
   *  SPARC_SWTRAP_IRQDIS
   *  SPARC_SWTRAP_IRQEN
   */
  IRQDIS_TRAP(SYM(syscall_irqdis));             ! 89 IRQ Disable syscall trap
  IRQEN_TRAP(SYM(syscall_irqen));               ! 8A IRQ Enable syscall trap

  SOFT_TRAP;                                    ! 8B
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! 8C - 8F
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! 90 - 93
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! 94 - 97
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! 98 - 9B
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! 9C - 9F
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! A0 - A3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! A4 - A7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! A8 - AB
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! AC - AF
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! B0 - B3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! B4 - B7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! B8 - BB
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! BC - BF
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! C0 - C3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! C4 - C7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! C8 - CB
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! CC - CF
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! D0 - D3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! D4 - D7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! D8 - DB
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! DC - DF
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! E0 - E3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! E4 - E7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! E8 - EB
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! EC - EF
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! F0 - F3
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! F4 - F7
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! F8 - FB
  SOFT_TRAP; SOFT_TRAP; SOFT_TRAP; SOFT_TRAP;   ! FC - FF

/*
 * The ROM expects a trap table at start. Give it a tiny one with at least the
 * window overflow/underflow handlers until we've initialized RAM and copied
 * the final trap table there.
 */

.seg    "text"
  PUBLIC(start)
  .global start, __bsp_mem_init

SYM(start):
start:
  RTRAP( 0, SYM(hard_reset) );                  ! 00 reset trap
  BAD_TRAP;                                     ! 01 instruction access
  BAD_TRAP;                                     ! 02 illegal instruction
  BAD_TRAP;                                     ! 03 privileged instruction
  BAD_TRAP;                                     ! 04 fp disabled
  WOTRAP(5, SYM(window_overflow_trap_handler)); ! 05 window overflow
  WUTRAP(6, SYM(window_underflow_trap_handler));! 06 window underflow
  BAD_TRAP;                                     ! 07 memory address not aligned

/*
 *  This is the hard reset code.
 */
        PUBLIC(hard_reset)
SYM(hard_reset):

	/* Flush caches */
	flush
	nop
	nop
	nop

	/* LEON config registers */
        set	SYM(LEON_REG), %g3

	/* Cache control register:
	 * [23]  = 1  (DS) Enable data snoop
	 * [16]  = 1  (IB) Enable burst instruction fetch
	 * [3:2] = 11 (ICS) Enable data cache
	 * [1:0] = 11 (DCS) Enable instruction cache
	 */
	set	0x81000f, %g1
  	st	%g1, [%g3 + 0x14]

	/* initialize mcfg1 and mcfg2 registers (ROM and RAM config) */
        set   LEON2_MCFG1_VALUE, %g1
	st    %g1, [%g3 + 0]
        set   LEON2_MCFG2_VALUE, %g1
	st    %g1, [%g3 + 4]

	/* Reset all registers to zero, in all windows */
	mov	%g0, %y
	clr	%g4
	clr	%g5
	clr	%g7
	mov	%asr17, %g1
	and	%g1, 0x1f, %g1
clear_window:
	mov	%g0, %l0
	mov	%g0, %l1
	mov	%g0, %l2
	mov	%g0, %l3
	mov	%g0, %l4
	mov	%g0, %l5
	mov	%g0, %l6
	mov	%g0, %l7
	mov	%g0, %o0
	mov	%g0, %o1
	mov	%g0, %o2
	mov	%g0, %o3
	mov	%g0, %o4
	mov	%g0, %o5
	mov	%g0, %o6
	mov	%g0, %o7
	subcc	%g1, 1, %g1
	bge	clear_window
	save

	/* Set trap base register to point to trap table in ROM */
        set     SYM(start), %g1    ! Initialize TBR to ROM
        mov     %g1, %tbr

	/* Reset interrupts */
	sub	%g0, 1, %g2
	st	%g0, [%g3 + 0x90]
	st	%g0, [%g3 + 0x98]
	st	%g2, [%g3 + 0x9C]

	/* Set stack pointer (and frame pointer) to end of RAM */
	set	LEON2_RDB_START, %l1
	mov	%l1, %sp
	mov     %sp, %fp

	/* Initialize UART1 (%g3 = LEON_REG still) */
        set   UART1_SCALER_VALUE, %g1
        st    %g1, [%g3 + 0x7c]
        set   UART1_CONTROL_VALUE, %g1
        st    %g1, [%g3 + 0x78]
        /* Reset UART status */
        st    %g0, [%g3 + 0x74]

	set   TIMER_COUNTER_VALUE, %g1
        st    %g1, [%g3 + 0x40]
        st    %g1, [%g3 + 0x44]
        set   TIMER_CONTROL_VALUE, %g1
        st    %g1, [%g3 + 0x48]

        /*
         *  Copy the initialized data to RAM
         *  FROM:   _endtext
         *  TO:     _data_start
         *  LENGTH: (__bss_start - _data_start) bytes
         */

        sethi %hi(_endtext),%g1
        or    %g1,%lo(_endtext),%g1     ! g1 = start of initialized data in ROM

        sethi %hi(_data_start),%g3
        or    %g3,%lo(_data_start),%g3  ! g3 = start of initialized data in RAM

        sethi %hi(__bss_start), %g2
        or    %g2,%lo(__bss_start),%g2  ! g2 = end of initialized data in RAM

	cmp   %g1, %g3
	be    clear_bss
	nop

copy_data:
        ldd   [%g1], %g4
        std   %g4 , [%g3]               ! copy this double word
        add   %g3, 8, %g3               ! bump the destination pointer
        add   %g1, 8, %g1               ! bump the source pointer
        cmp   %g3, %g2                  ! Is the pointer past the end of dest?
        bl    copy_data
        nop

clear_bss:
        /* clear the bss */
        sethi %hi(_end),%g3
        or    %g3,%lo(_end),%g3         ! g3 = end of bss
        mov   %g0,%g1                   ! so std has two zeros
zerobss:
        std    %g0,[%g2]
        add    %g2,8,%g2
        cmp    %g2,%g3
        bleu,a zerobss
        nop

	/* Setup trap table now that the RAM has been initialized */

setup_trap_table:
        set     SYM(trap_table), %g1    ! Initialize TBR
        mov     %g1, %tbr

        mov	%psr, %g1         	! Initialize WIM
	add	%g1, 1, %g2
	and	%g2, 0x7, %g2
	set	1, %g3
	sll	%g3, %g2, %g3
        mov     %g3, %wim

	or	%g1, 0xf20, %g1
        wr      %g1, %psr		! enable traps and disable ints

        nop
        nop
        nop

	/* RTEMS needs this in %g6 at start */
	set	_Per_CPU_Information, %g6   ! Set magic register %g6

	mov     %0, %o0                 ! command line
	call    SYM(boot_card)          ! does not return
	sub     %sp, 0x60, %sp          ! room for boot_card to save args

/* end of file */
