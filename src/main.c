// the lifeblood of the engine. don't remove these lines.
#include "./sniperengine/sniperengine.h"
#include "./ines_header.h"
#include <nes.h>


// some CHR data
banked(61) __attribute__((retain)) const u8 el_chr[] = {
    #embed "./chr/Menu_TFDLogo.bin"
};

banked(fixed_lo) const u8 funny_palette[] = {
    0x0f, 0x00, 0x10, 0x20,
    0x0f, 0x01, 0x11, 0x21,
    0x0f, 0x02, 0x12, 0x22,
    0x0f, 0x03, 0x13, 0x23,
};

int main(void) {
    PPU.control = 0b10100000;
    PPU.mask = 0b00000110;
    se_turn_off_rendering();

    set_chr_bank(0,0);
    set_chr_bank(1,2);
    set_chr_bank(2,4);
    set_chr_bank(3,5);
    set_chr_bank(4,6);
    set_chr_bank(5,7);
    se_donut_decompress_vram(el_chr,61);

    se_set_palette_background(funny_palette);

    se_turn_on_rendering();

    
    while(1){
        se_wait_vsync();
    }
}