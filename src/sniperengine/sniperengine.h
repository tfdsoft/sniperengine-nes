typedef unsigned char u8;
typedef unsigned short u16;
#define u24 __BitInt(24)
typedef unsigned long u32;

#define XSTR(x) #x
#define STR(x) XSTR(x)

#define NULL ((void*)0)

#define nametable_address_A(x,y) (0x2000 + ((y<<5) + x))
#define nametable_address_B(x,y) (0x2400 + ((y<<5) + x))
#define nametable_address_C(x,y) (0x2800 + ((y<<5) + x))
#define nametable_address_D(x,y) (0x2c00 + ((y<<5) + x))

#define banked(bank) __attribute__((section(".prg_rom_"STR(bank)),used))
#define file(symbol, bank) __attribute__((section((".prg_rom_"STR(bank))),retain)) const u8 symbol[]


__attribute__((section(".aligned"),retain)) struct OAM_BUF {
    unsigned char y;
    unsigned char tile;
    unsigned char attr;
    unsigned char x;
} OAM_BUF[64];


extern u8 se_ppu_ctrl_var, se_ppu_mask_var;
extern u8 se_palette_update;
extern void* se_post_nmi_ptr;


__attribute__((leaf)) void se_init();
__attribute__((leaf)) void nofunction();

__attribute__((leaf)) void banked_call_a000(u8 bank, void(*method)(void));
__attribute__((leaf)) void set_prg_c000(u8 bank);
__attribute__((leaf)) void set_prg_a000(u8 bank);
__attribute__((leaf)) void set_chr_bank(u8 window, u8 bank);

#define se_vram_address(address) __asm__("ldx #>"STR(address)"\n stx $2006 \n ldx #<"STR(address)"\n stx $2006")
__attribute__((leaf)) void se_vram_unrle(const void* data);
__attribute__((leaf)) void se_vram_donut_decompress(const u8 * data, u8 bank);



__attribute__((leaf)) void se_wait_vsync();
__attribute__((leaf)) void se_turn_off_rendering();
__attribute__((leaf)) void se_turn_on_rendering();

__attribute__((leaf)) void se_set_palette_background(const u8* data);
__attribute__((leaf)) void se_set_palette_sprites(const u8* data);
__attribute__((leaf)) void se_set_palette_all(const u8* data);
__attribute__((leaf)) void se_clear_palette();
__attribute__((leaf)) void se_set_palette_color(u8 index, u8 color);
__attribute__((leaf)) void se_set_palette_brightness_background(u8 bright);
__attribute__((leaf)) void se_set_palette_brightness_sprites(u8 bright);
__attribute__((leaf)) void se_set_palette_brightness_all(u8 bright);
__attribute__((leaf)) void se_fade_palette_to(u8 from, u8 to);

__attribute__((leaf)) void se_clear_sprites();


__attribute__((leaf)) void se_string_vram_buffer(
	const char *data, const u16 ppu_addr
);




__attribute__((leaf)) void se_memory_fill(void* ptr, u8 data, u16 length);
__attribute__((leaf)) void se_memory_copy(void* to, void* from, u16 length);



// == the compiler/linker figures these out ==
#include "musicDefines.h"
#include "musicBankData.h"
#include "music_soundTestTables.h"
#include "sfx_soundTestTables.h"
// ===========================================
#include "music/EXPORTS/sfx.h"


#include "famistudio_wrappers.c"
__asm__ (
    ".section .prg_rom_fixed_lo.famistudio_dpcm_bank_callback \n"
    "famistudio_dpcm_bank_callback: \n"
    "clc \n"
    "adc #"STR(dpcm_bank_0)" \n"
    "jmp set_prg_8000 \n"
    ".globl famistudio_dpcm_bank_callback \n"
);