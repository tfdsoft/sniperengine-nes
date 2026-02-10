#include <ines.h>
//#include <mapper.h>

// maxed out mmc3 prg
MAPPER_PRG_ROM_KB(512);

// extra memory!
MAPPER_PRG_NVRAM_KB(8);
MAPPER_USE_BATTERY;

// 32kb of chr-ram should be fine
MAPPER_CHR_ROM_KB(0);
MAPPER_CHR_RAM_KB(32);

// four screens of characters
//MAPPER_USE_4_SCREEN_NAMETABLE;

// multiregion
INES_TIMING_MULTIREGION;

__asm__ (
    "__four_screen = 1 \n"
    ".global __four_screen \n"
    // Expansion Port Sound Module
    "__console_type = 3 \n"
    ".global __console_type \n"
    "__extended_console_type = 4 \n" 
    ".global __extended_console_type \n"
);


__attribute__((leaf)) __asm__(
    ".section .init.100,\"ax\",@progbits \n"
    ".globl clearRAM \n"
    "clearRAM: \n"
        "lda #0 \n"
        "tax \n"
    "1: \n"
        "sta  $00,x \n"
        "pha \n"
        "sta $200,x \n"
        "sta $300,x \n"
        "sta $400,x \n"
        "sta $500,x \n"
        "sta $600,x \n"
        "sta $700,x \n"
        "inx \n"
        "bne 1b \n"

    // end of clearRAM

    /*
    ".section .init.280,\"ax\",@progbits \n"
        "lda #0 \n"
        "sta __rc2 \n"
        "sta __rc3 \n"
        "jsr set_vram_buffer \n"

    ".section .init.300,\"ax\",@progbits \n"
    
        // make sure the irq doesn't trigger itself
        "lda #255 \n"
        "sta irq_table+0 \n"
        "sta irq_table+6 \n"

        "lda #$37 \n"
        "jsr set_prg_a000 \n"

        "lda #$01 \n"
        "ldx #$00 \n"
        "ldy #$a0 \n"
        "jsr famistudio_init \n"
    */

        "lda #$c0\n"
        "sta $4017\n" // disable apu frame counter irq

/*
        "ldx #$00 \n"
        "tax \n"
        "dex \n"
        "ldy #$a0 \n"
        "jsr famistudio_sfx_init \n"
*/
);