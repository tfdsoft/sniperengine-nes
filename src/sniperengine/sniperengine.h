typedef unsigned char u8;
typedef unsigned short u16;
#define u24 __BitInt(24)
typedef unsigned long u32;

#define XSTR(x) #x
#define STR(x) XSTR(x)

#define banked(bank) __attribute__((section(".prg_rom_"STR(bank)),used))
#define file(symbol, bank) __attribute__((section((".prg_rom_"STR(bank))),retain)) const uint8_t symbol[]





__attribute__((leaf)) void se_donut_decompress_vram(const u8 * data, u8 bank);