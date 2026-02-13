/*==============================================
 *  ASSETS
 *  got any binary files or data that need to
 *  be included? Put them here.
 *==============================================
 *  USAGE:
 *  file(symbol, bank) = {
 *      #embed "<path/to/file>"
 *  }
 *  symbol: the keyword that gets created
 *          after adding the file to the project
 *  bank:   the bank where the file will reside
 *==============================================
 *  EXAMPLE
 *  to add a compressed graphics file:
 * 
 *  file(CHR_menu_font_pusab, 52) = {
 *      #embed "./chr/dnt/Menu_Font_Pusab.bin"
 *  }
**============================================*/


#define startup_bank 60
file(chr_menu_tfdlogo, startup_bank) = {
    #embed "./chr/dnt/Menu_TFDLogo.bin"
};
file(chr_menu_font_pusab, startup_bank) = {
    #embed "./chr/dnt/Menu_Font_Pusab.bin"
};
