typedef unsigned char u8;
typedef unsigned short u16;
#define u24 __BitInt(24)
typedef unsigned long u32;

#define XSTR(x) #x
#define STR(x) XSTR(x)

#define banked(bank) __attribute__((section(".prg_rom_"STR(bank)),used))
#define file(symbol, bank) __attribute__((section((".prg_rom_"STR(bank))),retain)) const uint8_t symbol[]


__attribute__((section(".aligned"),retain)) struct OAM_BUF {
    unsigned char y;
    unsigned char tile;
    unsigned char attr;
    unsigned char x;
} OAM_BUF[64];



__attribute__((leaf)) void banked_call_a000(u8 bank, void(*method)(void));
__attribute__((leaf)) void set_prg_c000(u8 bank);
__attribute__((leaf)) void set_prg_a000(u8 bank);
__attribute__((leaf)) void set_chr_bank(u8 window, u8 bank);

__attribute__((leaf)) void se_donut_decompress_vram(const u8 * data, u8 bank);

__attribute__((leaf)) void se_wait_vsync();
__attribute__((leaf)) void se_turn_off_rendering();
__attribute__((leaf)) void se_turn_on_rendering();

__attribute__((leaf)) void se_set_palette_background(const u8* data);
__attribute__((leaf)) void se_set_palette_sprites(const u8* data);
__attribute__((leaf)) void se_set_palette_all(const u8* data);
__attribute__((leaf)) void se_clear_palette();
__attribute__((leaf)) void se_set_palette_color(u8 index, u8 color);