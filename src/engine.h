/** @file
    Interface of game engine.

 */
#include <stdbool.h>
#ifndef ENGINE_H
#define ENGINE_H

/**
 * Initializes a game. Needed before first INIT.
 */
void startGame();

/**
 * Frees memory and prints (into stderr) a winner. Needed after finishing game.
 * @return 0 if the game is won
 * @return 1 if the game is drawn
 * @return 2 if the game is lost
 */
int endGame();

/**
 * Initializes a game with size of a board, number of rounds and positions of kings.
 * @param[in] n The size of a board.
 * @param[in] k Number of rounds.
 * @param[in] p Player ID.
 * @param[in] x1 Start column of the first player's king.
 * @param[in] y1 Start row of the first player's king.
 * @param[in] x2 Start column of the second player's king.
 * @param[in] y2 Start row of the second player's king.
 * @return false The input data is not valid.
 * @return true The input data is valid.
 */
bool init(int n, int k, int p, int x1, int y1, int x2, int y2);

/**
 * Makes a move.
 * @param[in] x1 Column number before a move.
 * @param[in] y1 Row number before a move.
 * @param[in] x2 Column number after a move.
 * @param[in] y2 Row number after a move.
 * @return false The input data is not valid.
 * @return true The input data is valid.
 */
bool move(int x1, int y1, int x2, int y2);

/**
 * Produces a new knight.
 * @param[in] x1 Column of producing peasant.
 * @param[in] y1 Row of producing peasant.
 * @param[in] x2 Start column of a new knight.
 * @param[in] y2 Start row of a new knight.
 * @return false The input data is not valid.
 * @return true The input data is valid.
 **/
bool produceKnight(int x1, int y1, int x2, int y2);

/**
 * Produces a new peasant.
 * @param[in] x1 Column of producing peasant.
 * @param[in] y1 Row of producing peasant.
 * @param[in] x2 Start column of a new peasant.
 * @param[in] y2 Start row of a new peasant.
 * @return false The input data is not valid.
 * @return true The input data is valid.
 **/
bool producePeasant(int x1, int y1, int x2, int y2);

/**
 * Ends the turn of a player. Needed after the sequence of moves.
 * @return true after the last round,
 * @return false if there are some rounds left.
 **/
bool endTurn();

/**
 * Frees the lists of pieces of both players.
 **/
void clearAll();

/**
 * Checks the winner.
 * @return true if someone's king is beaten,
 * @return false otherwise.
 **/
bool checkWinner();

/**
 * Checks the ID of a current player.
 **/
int checkCurrentPlayer();

/**
 * Checks the ID given by script.
 **/
int checkMyID();

#endif /* ENGINE_H */
