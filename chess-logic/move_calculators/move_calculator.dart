import '../chess_move.dart';
import '../chess_position.dart';
import '../piece.dart';

class MoveCalculator {

  static bool checkForValidMove(ChessPosition startPosition, ChessPosition endPosition, ChessPiece myPiece, ChessBoard board, Set<ChessMove> potentialMoves) {
    if(!endPosition.isInBounds()) {
      return false;
    }
    ChessPiece? piece = board.getPiece(endPosition);
    //If square is empty, add to valid moves list and continue
    if(piece == null) {
      potentialMoves.add(ChessMove(startPosition, endPosition, null, null, myPiece));
      return true;
    }
    //If there is a piece in the square on the opposite team, add capture move and stop
    else if(piece.color != myPiece.color) {
      potentialMoves.add(ChessMove(startPosition, endPosition, null, piece, myPiece));
      return false;
    }
    //If piece in square is on your team, stop and don't add move
    else {
      return false;
    }
  }
}