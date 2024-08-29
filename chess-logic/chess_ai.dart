import 'dart:async';

import 'package:stockfish/stockfish.dart';

import 'chess_move.dart';

class ChessAI {
  final Stockfish stockfish = Stockfish();
  Completer<bool> boolCompleter = Completer<bool>();
  Completer<String> moveCompleter = Completer<String>();

  //Set up the listener for the output of stockfish, which will handle the outputs as they come in.
  ChessAI() {
    stockfish.stdout.listen((output) {
      print(output);
      if(output == "readyok") {
        boolCompleter.complete(true);
      }
      if(output.contains("bestmove")) {
        List<String> separatedOutput = output.split(" ");
        String move = separatedOutput.elementAt(1);
        moveCompleter.complete(move);
      }
    });
  }

  //Waits for the chess engine to start, gives it commands to confirm engine is ready, sets starting position of board, and skill level of AI
  Future<bool> isReady(int skillLevel) async {
    await waitUntilReady();
    //Completer is used to return success asynchronously once response has return from output
    boolCompleter = Completer();
    //Command confirms AI is ready to receive commands
    stockfish.stdin = "isready";
    Future<bool> success = boolCompleter.future;
    //Sets board state to starting position
    stockfish.stdin = "position startpos";
    //Sets difficulty to provided skill level
    stockfish.stdin = "setoption name Skill Level $skillLevel";
    return success;
  }

  //Waits until state of engine is "ready"
  Future<void> waitUntilReady() async {
    while (stockfish.state.value != StockfishState.ready) {
      if(stockfish.state.value == StockfishState.error) {
        print("something went wrong");
        break;
      }
      await Future.delayed(Duration(seconds: 1));
    }
  }

  //AI takes 3 seconds to think about the best move to make given the current board state.
  Future<String> determineNextMove() {
    moveCompleter = Completer();
    stockfish.stdin = "go movetime 3000";
    Future<String> results = moveCompleter.future;
    return results;
  }

  //Loads the current movelist into the AI (doesn't seem to work the way I expected)
  void loadMoveList(List<ChessMove> moveList) {
    String moveListString = "";
    for(ChessMove move in moveList) {
      moveListString += "${move.convertMove()} ";
    }
    stockfish.stdin = "position startpos $moveListString";
  }

  //Loads the board state to an AI via a FEN string
  void loadFENString(String fenString) {
    stockfish.stdin = "position fen $fenString";
  }
  void dispose() {
    stockfish.dispose();
  }
}

