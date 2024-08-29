import '../chess_move.dart';
import '../chess_position.dart';
import '../piece.dart';
import 'move_calculator.dart';

class RookCalculator {
  //Calculate the moves a rook can make at this position
  static Set<ChessMove> pieceMoves(ChessPosition position, ChessBoard board) {
    Set<ChessMove> potentialMoves = {};
    ChessPiece? myPiece = board.getPiece(position);
    //If position we are looking at is not a piece, return empty list;
    if(myPiece == null) {
      return potentialMoves;
    }
    //Up
    for(int i = position.row + 1; i < 8; ++i) {
      ChessPosition newPosition = ChessPosition(i, position.col);
      if(!MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves)) {
        break;
      }
    }

    //Down
    for(int i = position.row - 1; i >= 0; --i) {
      ChessPosition newPosition = ChessPosition(i, position.col);
      if(!MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves)) {
        break;
      }
    }

    //Right
    for(int i = position.col + 1; i < 8; ++i) {
      ChessPosition newPosition = ChessPosition(position.row, i);
      if(!MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves)) {
        break;
      }
    }

    //Left
    for(int i = position.col - 1; i >= 0; --i) {
      ChessPosition newPosition = ChessPosition(position.row, i);
      if(!MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves)) {
        break;
      }
    }
    return potentialMoves;
  }
}