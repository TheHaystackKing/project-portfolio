
# Chess Logic
This repository contains a segment of code from my capstone project, where we developed a mobile game for a client based on the classic game of chess. The project was implemented in Dart, the language used by Flutter, to ensure cross-platform compatibility for both Android and iOS, as we lacked the resources to develop separate native versions for each platform.

Due to the commercial nature of the project, I am unable to include the complete source code. However, I have obtained permission to showcase this section of code, which handles the back-end logic for the chess game. Please note that to comply with these restrictions, certain references to the original project have been removed, meaning this code will not compile as-is. There are also references to classes and methods that are not included in this sample, as they pertain to other parts of the project not relevant to this showcase.

## Code Overview

This code sample is comprised of the following components:

**Move Calculators** - Methods for each piece (except for the Queen, who uses a combination of Rook and Bishop methods) that calculate the possible moves from any position on the board, not considering moves that would place the player in check.

**Chess Piece, Position, Move** - Components that represent fundamental elements of the game, primarily serving to store variables and provide helper methods used throughout the project.

**Chess Board** - The core class managing the back-end logic of the chess game. This includes an 8x8 array representing the chessboard and various methods that manage the game state. These methods include determining if a player is in check or checkmate, identifying stalemate situations, generating a list of all valid moves considering check conditions, and supporting the chess AI.

**Chess AI** - An adapter class for the Flutter port of the Stockfish chess engine, providing methods to initialize the AI, load the current board state, and request the next move.
