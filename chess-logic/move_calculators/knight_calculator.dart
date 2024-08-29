import '../chess_move.dart';
import '../chess_position.dart';
import '../piece.dart';
import 'move_calculator.dart';

class KnightCalculator {
  static Set<ChessMove> pieceMoves(ChessPosition position, ChessBoard board) {
    Set<ChessMove> potentialMoves = {};
    ChessPiece? myPiece = board.getPiece(position);
    if(myPiece == null) {
      return potentialMoves;
    }

    //2 Up 1 left
    ChessPosition newPosition = ChessPosition(position.row + 2, position.col - 1);
    MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves);

    //2 Up 1 right
    newPosition = ChessPosition(position.row + 2, position.col + 1);
    MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves);

    //2 right 1 up
    newPosition = ChessPosition(position.row + 1, position.col + 2);
    MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves);

    //2 right 1 down
    newPosition = ChessPosition(position.row - 1, position.col + 2);
    MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves);

    //2 down 1 right
    newPosition = ChessPosition(position.row - 2, position.col + 1);
    MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves);

    //2 down 1 left
    newPosition = ChessPosition(position.row - 2, position.col - 1);
    MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves);

    //2 left 1 up
    newPosition = ChessPosition(position.row + 1, position.col - 2);
    MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves);

    //2 left 1 down
    newPosition = ChessPosition(position.row - 1, position.col - 2);
    MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves);

    return potentialMoves;
  }
}
