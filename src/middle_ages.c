 /** @file
    Modified version of game engine. Simple AI programme. It checks the ID given by the script and, 
    * when it is time for a move, prints END_TURN message.
    * @return 0 if the game is won
    * @return 1 if the game is drawn
    * @return 2 if the game is lost
    * @return 42 if the input is incorrect
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "parse.h"
#include "engine.h"

/**
 * Prints (into stder) error message, terminates the game and frees memory if the input data is incorrect.
 **/
static void putError() {
	clearAll();
	fprintf(stderr, "input error\n");
	return;
}

/**
 * Main function of the game.
 **/
int main() {

    startGame();

    Command newCommand;
    bool initCorrect;
    
	newCommand = parseCommand();
	if (strcmp(newCommand.name, "INIT") == 0) {
		initCorrect = init(newCommand.data[0],
		newCommand.data[1],
        newCommand.data[2],
        newCommand.data[3],
        newCommand.data[4],
        newCommand.data[5],
        newCommand.data[6]);
        if (!initCorrect) {
			putError();
			return 42;
		}
	} else {
		putError();
		return 42;			
	}
	
    while (1) {
		if (checkWinner())  {
			break;
		}
		
		if (checkCurrentPlayer() == checkMyID()) {
			printf("END_TURN\n");
			fflush(stdout);
			if (endTurn()) {
				break;
			}
			continue;
		}
		
		newCommand = parseCommand();
        if (strcmp(newCommand.name, "MOVE") == 0) {
			if (!move(newCommand.data[0],
				newCommand.data[1],
				newCommand.data[2],
				newCommand.data[3])) {
					putError();
					return 42;
				}
		} else if (strcmp(newCommand.name, "PRODUCE_KNIGHT") == 0) {
			if (!produceKnight(newCommand.data[0],
				newCommand.data[1],
				newCommand.data[2],
				newCommand.data[3])) {
					putError();
					return 42;
				}
		} else if (strcmp(newCommand.name, "PRODUCE_PEASANT") == 0) {
			if (!producePeasant(newCommand.data[0],
				newCommand.data[1],
				newCommand.data[2],
				newCommand.data[3])) {
					putError();
					return 42;
				}			
		} else if (strcmp(newCommand.name, "END_TURN") == 0) {
			if (endTurn()) {
				break;
			}
			continue;
		} else {
			putError();
			return 42;
		}
    }

    return endGame();
}
