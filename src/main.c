// the lifeblood of the engine. don't remove these lines.
#include "./sniperengine/sniperengine.h"
#include "./ines_header.h"



// some CHR data
banked(61) const u8 el_chr[] = {
    #embed "./chr/Menu_TFDLogo.bin"
};


banked(fixed_lo) int main(void) {

    se_donut_decompress_vram(el_chr,61);

    return 0;
}