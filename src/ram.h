/*==============================================
 *  RAM HEADER
 *  any global variables your game uses
 *  should go here.
**==============================================
 *  for battery-backed variables:
 *    - add `sram` to the beginning of your
 *      declaration.
**============================================*/
















/*==============================================
 *  You shouldn't have to touch anything
 *  below this point.
**============================================*/

// keep this here for music
#define sound_test_bank 0

// generally, you want a state machine to
// control your game loop with
u8 gamestate;

sram u8 funny_saved_variable_name;