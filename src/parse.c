 /** @file
    Parser of input commands.

 */
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <string.h>
#include "parse.h"

/**
 * Auxiliary function, checks the correctness of white signs in the input line.
 **/
static bool checkInputCorrectness(char* input) {
	if (input[0] == ' ' || input[0] == '\t' || input[0] == '\n') {
		return false;
	}
	for (int i = 1; i < 100; i++) {
		if (input[i] == '\n') {
			if (input[i-1] == ' ') {
				return false;
			} else {
				return true;
			}
		} else if (input[i] == ' ') {
			if (input[i-1] == ' ') {
				return false;
			}
		} else if (input[i] == '\t') {
			return false;
		}
	}
	return false;
}

Command parseCommand() {
	Command ret;
	char line[100];
	int temp = 0;
	int temp2;
	if (fgets(line, 100, stdin) == NULL) {
		strcpy(ret.name, "WRONG_INPUT");
		return ret;
	}

	if(sscanf(line, "%s", ret.name) < 1) {
		strcpy(ret.name, "WRONG_INPUT");
		return ret;
	}
	
	if (strcmp(ret.name, "END_TURN") == 0) {
		if (!checkInputCorrectness(line) || sscanf(line, "%*s%d", &temp2) > 0) {
			strcpy(ret.name, "WRONG_INPUT");
			}
		return ret;
	}
	temp = sscanf(line, "%*s%d%d%d%d", &ret.data[0], &ret.data[1],
			&ret.data[2], &ret.data[3]);
	if (temp < 4) {
		strcpy(ret.name, "WRONG_INPUT");
	}
	if (strcmp(ret.name, "INIT") == 0) {
		temp = sscanf(line, "%*s%*d%*d%*d%*d%d%d%d%d", &ret.data[4], 
			&ret.data[5], &ret.data[6], &temp2);
		if (temp < 3 || temp > 3 || !checkInputCorrectness(line)) {
			strcpy(ret.name, "WRONG_INPUT");
		}
	} else {
		if (!checkInputCorrectness(line) || sscanf(line, "%*s%*d%*d%*d%*d%d", &temp2) > 0) {
			strcpy(ret.name, "WRONG INPUT");
		}
	}
	return ret;
}
