# Tron with Friends
#### Niveen Jegatheeswaran, Sanjam Sigdel, Tabeeb Yeamin, Johnson Zhong
##### CSCB58: Winter 2019 Final Project

_"Tron with Friends"_ is a game based on the movie Tron. The game is played with 2 players, the objective of the game is to make the other player crash into the trail left by your character. The character moves forward while leaving a trail behind of the colour of the player's choosing, the player can choose to turn left or right.The game is over when one of the characters hits any trail on the screen, including their own, and the other character is claimed the winner and wins a point.

## Controls
### On Keybored
* Player 1 (Purple): <kbd>W</kbd><kbd>A</kbd><kbd>S</kbd><kbd>D</kbd>
* Player 2 (Blue): <kbd>↑</kbd><kbd>↓</kbd><kbd>←</kbd><kbd>→</kbd>
### On DE2 Board
* SW[0]: Enable scoring
* SW[1]: Reset scores
* KEY[0]: Increment score for Player 1
* KEY[3]: Increment score for Player 2

## Required Hardware
- Altera DE2 Board (Cyclone IV board)
   - Use `de2.qsf` for pin assignments
- VGA Display
- PS/2 Keyboard

## Attributions
1. Link: http://www.instructables.com/id/PS2-Keyboard-for-FPGA/

   Description: Used the Keyboard.v file as a basis for our PS/2 keyboard input, adding additional scan codes for more keys.
   
2. Link: http://www.eecg.utoronto.ca/~jayar/ece241_08F/vga/vga-bmp2mif.html

   Description: Used to convert our bitmap images to .mif files to use as the background for our game's start screen.

1. CSCB58 - Lab 4
   
   Description: Rate divider code and counter

2. Link: https://github.com/rahul-kumar-saini/TurfWars
   
   Description: Rate divider to implement the clock to use for player movement speed

3. CSCB58 - Lab 6

   Desciption: Displaying pixels on the screen at specified coordinates

4. http://www.instructables.com/id/PS2-Keyboard-for-FPGA/

   Desciption: Use keyboard as input for pixel movement

5. http://electrosofts.com/verilog/loop_statements.html

   Description: Writing for loops to initialize borders

6. http://www.gstitt.ece.ufl.edu/courses/spring18/eel4712/labs/lab6/

   Desciption: Converting image files to .mif files