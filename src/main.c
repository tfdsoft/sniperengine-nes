// the lifeblood of the engine. don't remove these lines.
#include <nes.h>

// sniperengine data
#include "sniperengine/sniperengine.h"
#include "ines_header.h"
#include "assets.c"

// ram
#include "ram.h"

// music data
#include "musicBankData.h"
#include "music/EXPORTS/sfx.h"

// assembly passthroughs
#include "./funny_custom_routines.h"

// gamestates
#include "startup.c"
#include "greet_message.c"


banked(fixed.main) int main(void) {
    PPU.control = se_ppu_ctrl_var = 0b10100000;
    PPU.mask = se_ppu_mask_var = 0b00000110;
    PPU.status;
    se_init();

    se_set_first_music_bank(music_bank_0);
    se_set_first_dpcm_bank(dpcm_bank_0);
    se_set_sfx_bank(0);
    famistudio_init(1,0xa000);

    se_post_nmi_ptr = se_music_update;

    se_clear_palette();

    while(1){
        __asm__("sei");
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
        //se_post_nmi_ptr = nofunction;
    }
}