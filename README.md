# Tron with Friends
#### Niveen Jegatheeswaran, Sanjam Sigdel, Tabeeb Yeamin, Johnson Zhong
##### CSCB58: Winter 2019 Final Project

###### Note: This project was worked on in a "pair programming" environment on one main computer, thus the commit history does not accurately reflect individual contributions.

_"Tron with Friends"_ is a game based on the movie Tron. The game is played with 2 players, the objective of the game is to make the other player crash into the trail left by your character. The character moves forward while leaving a trail behind of the colour of the player's choosing, the player can choose to turn left or right.The game is over when one of the characters hits any trail on the screen, including their own, and the other character is claimed the winner and wins a point.

## Controls
# On Keyboard
* Player 1 (Purple): <kbd>W</kbd><kbd>A</kbd><kbd>S</kbd><kbd>D</kbd>
* Player 2 (Blue): <kbd>↑</kbd><kbd>↓</kbd><kbd>←</kbd><kbd>→</kbd>
# On DE2 Board
* 

## Required Hardware
- Altera DE2 Board
   - For pin assignments, use `DE2cyclone4.qsf` if you are using a Cyclone IV board and `DE2cyclone2.qsf` for Cyclone II
- VGA Display
- PS/2 Keyboard

## Attributions
1. Link: http://www.instructables.com/id/PS2-Keyboard-for-FPGA/

   Description: Used the Keyboard.v file as a basis for our PS/2 keyboard input, adding additional scan codes for more keys.
   
2. Link: http://www.eecg.utoronto.ca/~jayar/ece241_08F/vga/vga-bmp2mif.html

   Description: Used to convert our bitmap images to .mif files to use as the background for our game's start screen.