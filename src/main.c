// the lifeblood of the engine. don't remove these lines.
#include <nes.h>


#include "sniperengine/sniperengine.h"
#include "ines_header.h"
#include "ram.h"



#include "state_startup.c"


banked(fixed.main) int main(void) {
    PPU.control = se_ppu_ctrl_var = 0b10100000;
    PPU.mask = se_ppu_mask_var = 0b00000110;
    PPU.status;
    se_init();

    set_prg_a000(music_bank_0);
    famistudio_init(1,0xa000);

    se_post_nmi_ptr = se_music_update;
    se_irq_ptr = nofunction;
    

    se_clear_palette();

    
    while(1){
        se_wait_vsync();
        se_turn_off_rendering();
        se_clear_sprites();

        switch (gamestate){
            default:
                jsrfar_noargs(60,state_startup);
                break;
            case 0xff:
                jsrfar_noargs(60,thegreet_message);
                break;
        }
        se_post_nmi_ptr = nofunction;
    }
}