// the lifeblood of the engine. don't remove these lines.
#include "sniperengine/sniperengine.h"
#include "ines_header.h"
#include "ram.h"
#include <nes.h>

#include "state_startup.c"


banked(fixed_lo.main) int main(void) {
    PPU.control = se_ppu_ctrl_var = 0b10100000;
    PPU.mask = se_ppu_mask_var = 0b00000110;
    PPU.status;
    //se_turn_off_rendering();

    set_chr_bank(0,0);
    set_chr_bank(1,2);
    set_chr_bank(2,4);
    set_chr_bank(3,5);
    set_chr_bank(4,6);
    set_chr_bank(5,7);

    se_clear_palette();

    //se_turn_on_rendering();
    while(1){
        se_wait_vsync();
        se_turn_off_rendering();
        se_clear_sprites();

        switch (gamestate){
            default:
                banked_call_a000(61,state_startup);
        }
    }
}