import '../chess_move.dart';
import '../chess_position.dart';
import '../piece.dart';
import 'move_calculator.dart';

class BishopCalculator {
  static Set<ChessMove> pieceMoves(ChessPosition position, ChessBoard board) {
    Set<ChessMove> potentialMoves = {};
    ChessPiece? myPiece = board.getPiece(position);
    //If position we are looking at is not a piece, return empty list;
    if(myPiece == null) {
      return potentialMoves;
    }

    //Up-left
    for(int i = 1; i < 8; ++i) {
      ChessPosition newPosition = ChessPosition(position.row + i, position.col - i);
      if(!MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves)) {
        break;
      }
    }

    //Up-Right
    for(int i = 1; i < 8; ++i) {
      ChessPosition newPosition = ChessPosition(position.row + i, position.col + i);
      if(!MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves)) {
        break;
      }
    }

    //down-left
    for(int i = 1; i < 8; ++i) {
      ChessPosition newPosition = ChessPosition(position.row - i, position.col - i);
      if(!MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves)) {
        break;
      }
    }

    //down-right
    for(int i = 1; i < 8; ++i) {
      ChessPosition newPosition = ChessPosition(position.row - i, position.col + i);
      if(!MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves)) {
        break;
      }
    }
    return potentialMoves;
  }
}