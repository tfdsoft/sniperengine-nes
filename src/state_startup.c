#define state_startup_bank 60

// some CHR data
banked(state_startup_bank.data) __attribute__((retain)) const u8 chr_startup[] = {
    #embed "./chr/dnt/Menu_TFDLogo.bin"
};
banked(state_startup_bank.data) __attribute__((retain)) const u8 chr_font_pusab[] = {
    #embed "./chr/dnt/Menu_Font_Pusab.bin"
};

banked(state_startup_bank.data) const u8 pal_startup[] = {
    0x20, 0x10, 0x00, 0x0f,
    0x0f, 0x01, 0x11, 0x21,
    0x0f, 0x02, 0x12, 0x22,
    0x0f, 0x03, 0x13, 0x23,
};

banked(state_startup_bank.data) const unsigned char nt_startup[] = {
    0x01,0x00,0x01,0xfe,0x00,0x01,0x45,0x80,0x81,0x00,0x01,0x12,0xc0,0x00,0x01,0x08,
0x82,0x83,0x84,0x85,0x00,0x01,0x0d,0xc1,0x00,0xc2,0xc3,0xc4,0x00,0x01,0x07,0x86,
0x87,0x88,0x89,0x00,0x01,0x09,0xc5,0xc6,0xc7,0xc8,0xc9,0xca,0x00,0xcb,0xcc,0xcd,
0x00,0x01,0x06,0x8a,0x8b,0x8c,0x8d,0x00,0x00,0x8e,0x8f,0x90,0x91,0x92,0x93,0x94,
0x95,0x00,0xce,0xcf,0xd0,0xd1,0x00,0x01,0x0d,0x96,0x97,0x98,0x99,0x9a,0x9b,0x9c,
0x9d,0x9e,0x9f,0xa0,0xa1,0xa2,0x00,0xd2,0xd3,0xd4,0xd5,0xd6,0xd7,0xd8,0xd9,0xda,
0xdb,0xdc,0xdd,0xde,0x00,0x01,0x04,0x96,0x97,0xa3,0xa4,0xa5,0x00,0x01,0x07,0xdf,
0xe0,0xe1,0xe2,0xe3,0xe4,0xe5,0xe6,0xe7,0xe8,0xe9,0xea,0xeb,0xec,0x00,0x01,0x04,
0x96,0x97,0xa6,0xa7,0xa8,0x00,0x01,0x0c,0xee,0xef,0xf0,0xf1,0xf2,0xf3,0xf4,0xf5,
0xf6,0xed,0x00,0x01,0x03,0xa9,0xaa,0x00,0x00,0xab,0x00,0x01,0x0e,0xf7,0xf8,0x00,
0x01,0xfe,0x00,0x01,0xc7,0x01,0x00
};

banked(state_startup_bank.func) void state_startup(){
    se_vram_address(0);
    se_memory_fill((void*)0x2007,0,256);
    se_vram_donut_decompress(chr_font_pusab, state_startup_bank);
    se_vram_donut_decompress(chr_startup, state_startup_bank);

    se_vram_address(0x2000);
    se_vram_unrle(nt_startup);

    se_set_palette_background(pal_startup);

    se_vram_address(nametable_address_A(2,27));
    //se_memory_fill((void*)0x2007, 0x20, 32);

    // enable music
    se_post_nmi_ptr = se_music_update;


    se_set_palette_brightness_all(0);
    se_turn_on_rendering();
    for(char stall=8; stall>0; stall--){
        se_wait_vsync();
    }
    se_fade_palette_to(0,4);

    for(char stall=8; stall>0; stall--){
        se_wait_vsync();
    }

    for(char i=0;i<5;i++)
    se_string_vram_buffer("THIRTY TWO BYTES! ABSOLUTE PEAK!", nametable_address_A(0,(2+i)));


    se_sfx_play(sfx_boot,0);
    
    for(char stall=90; stall>0; stall--){
        se_wait_vsync();

        se_set_palette_brightness_all(4);
        if((stall >= 85)) se_set_palette_brightness_all(5);
        //if((stall >= 83) ) se_set_palette_brightness_all(5);
        
    }

    se_fade_palette_to(4,8);
    se_turn_off_rendering();

    /*
    vram_adr(0x0200);
    sedonut_decompress_vram(chr_menu_font_pvz_filled, chr_bank_0);
    sedonut_decompress_vram(chr_menu_window, chr_bank_0);

    if(player1_hold & PAD_SELECT) {
        sfx_play(sfx_explode_11,0);
        vram_adr(0x2000);
        vram_fill(0, 0x3c0);
        memfill((u8*)0x6000, 0, 0x2000);

        str_vram_buffer(str_ripsave, 0x21c3);

        se_turn_on_rendering();
        pal_fade_to(0,4);
        for(char stall = 180; stall>0; stall--){
            ppu_wait_nmi();
        }
        pal_fade_to(4,0);
        se_turn_off_rendering();
    }*/

    gamestate = 0xff;
    return;
}





banked(state_startup_bank.data) const u8 greet_irq_table[] = {
    110,// scanlines to wait
    0,      // lo and hi bytes
    0,      // of function address
    0,  // lo X
    0,  // hi X
    111,// lo Y
    0,  // hi Y

    7,  // scanlines to wait
    0,      // lo and hi bytes
    0,      // of function address
    0,  // lo X
    0,  // hi X
    120,// lo Y
    0,  // hi Y

    255,
    0,
    0
};

banked(state_startup_bank.func) void thegreet_message(){

    u16 scroll = 0;

    se_vram_address(nametable_address_A(0,0));
    se_memory_fill((void*)0x2007, 0, 1024);
    se_string_vram_buffer("WELCOME TO SNIPERENGINE.", nametable_address_A(4,14));

    se_post_nmi_ptr = se_music_update;

    se_memory_copy((void*)se_irq_table,(void*)greet_irq_table,sizeof(greet_irq_table));
    
    // play sample
    //se_irq_table[0] = 1;    // playback rate
    //se_irq_table[1] = 0xd0;
    //se_irq_table[2] = 0x00;
    //(*(u8*)0x00d1) = 0x00;
    //(*(u8*)0x00d2) = 0xc0;
    //se_sample_in_progress = 1;
    //set_prg_c000(1);

    se_write_function_to_irq_table(custom_irq_that_updates_scroll, 1);
    se_write_function_to_irq_table(custom_irq_that_updates_scroll, 8);
    se_write_function_to_irq_table(nofunction, 15);

    

    
    se_music_play(0);

    se_set_palette_brightness_all(4);
    se_turn_on_rendering();


    __asm__("cli");

    while(1){
        se_wait_vsync();

        scroll++;
        se_irq_table[3] = lo(scroll);
        se_irq_table[4] = hi(scroll);

        se_one_vram_buffer(
            (0x30 + (__prg_8000 >> 4)),
            nametable_address_A(2,2)
        );
        se_one_vram_buffer(
            (0x30 + (__prg_8000 & 15)),
            nametable_address_A(3,2)
        );


        for (char i=0; i<8; i++)
        se_one_vram_buffer(
            0x30 + ((joypad1.hold >> i) & 1),
            nametable_address_A((6+i),2)
        );

        if(joypad1.press_a) {
            se_play_sample(0xc000, 1, 1);
            se_wait_vsync();
        }
        if(joypad1.press_b) {
            break;
        }
    }
}


file(samples_0, 1) = {
    #embed "./samples/geometryDash0.pcm"
};
file(samples_1, 2) = {
    #embed "./samples/geometryDash1.pcm"
};
file(samples_2, 3) = {
    #embed "./samples/geometryDash2.pcm"
};