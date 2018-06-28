# Galagodv1
#### AI Which uses a genetic alagorithm to play galaga very poorly (Version 1)
  In this script, I created an AI which could play Galaga, this is my first iteration
which does work, but the algorithm could be more optimal.

### The Genetic Algorithm
When the game starts, the AI takes a savestate of the game, in order to return to if it dies.
A random population of X positions will be generated. The AI will move to each given X Position,
and fire two bullets when it arrives. The difference in score will be recorded, and the X position
will be scored based on that value. If the AI dies, the algorithm subtracts 1000 points to the last 5
xposition the ai moved to, forcing the AI to try new moves where it died at on its next iteration.

Over time, you will see the AI does get progressively better, but i feel it just learns too slowly.

### How to use:
You must have a rom of the US, NES Version of galaga and FCEUX emulator installed.
  - Load up Galaga in FCEUX,
  - Start a 1 player game,
  - When the ship spawns,load and run the LUA script. You want to be sure you do this after the ship spawns, and before the enemies start swinging in. I usually wait until "Stage 1" dissapears, The script could get stuck in a loop if you run the script too early.
 - Just let it do its thing. You can turn emulation speed up, it won't affect the affect learning, since the ai learns frame by frame.

![Galagod](https://i.imgur.com/4xRa5SJ.gif)
