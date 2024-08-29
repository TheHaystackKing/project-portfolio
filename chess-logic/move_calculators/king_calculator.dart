import '../chess_move.dart';
import '../chess_position.dart';
import '../piece.dart';
import 'move_calculator.dart';

class KingCalculator {
  static Set<ChessMove> pieceMoves(ChessPosition position, ChessBoard board) {
    Set<ChessMove> potentialMoves = {};
    ChessPiece? myPiece = board.getPiece(position);
    if(myPiece == null) {
      return potentialMoves;
    }
    //UP
    ChessPosition newPosition = ChessPosition(position.row + 1, position.col);
    MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves);

    //DOWN
    newPosition = ChessPosition(position.row - 1, position.col);
    MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves);


    //RIGHT
    newPosition = ChessPosition(position.row, position.col + 1);
    MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves);

    //DOWN
    newPosition = ChessPosition(position.row, position.col - 1);
    MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves);

    //UP-LEFT
    newPosition = ChessPosition(position.row + 1, position.col - 1);
    MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves);

    //UP-RIGHT
    newPosition = ChessPosition(position.row + 1, position.col + 1);
    MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves);

    //DOWN-LEFT
    newPosition = ChessPosition(position.row - 1, position.col - 1);
    MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves);

    //DOWN-RIGHT
    newPosition = ChessPosition(position.row - 1, position.col + 1);
    MoveCalculator.checkForValidMove(position, newPosition, myPiece, board, potentialMoves);

    if(canCastleLeft(position, board, myPiece)) {
      potentialMoves.add(ChessMove(position, ChessPosition(position.row, position.col - 2), ChessPieceType.castle, null, myPiece));
    }
    if(canCastleRight(position, board, myPiece)) {
      potentialMoves.add(ChessMove(position, ChessPosition(position.row, position.col + 2), ChessPieceType.castle, null, myPiece));
    }

    return potentialMoves;
  }

  static bool canCastleLeft(ChessPosition position, ChessBoard board, ChessPiece myPiece) {
    if(!myPiece.hasMoved) {
      ChessPiece? leftHandRook = board.getPiece(ChessPosition(position.row, 0));
      //Check that rook is your rook and it has not moved yet
      if (leftHandRook != null && leftHandRook.color == myPiece.color &&
          leftHandRook.type == ChessPieceType.rook && !leftHandRook.hasMoved) {
        ChessPosition tempPosition = ChessPosition(position.row, position.col);
        bool canCastle = true;
        //Check if all spaces between king and rook are empty
        while (tempPosition != ChessPosition(position.row, 1)) {
          tempPosition.col -= 1;
          ChessPiece? piece = board.getPiece(tempPosition);
          if (piece != null) {
            canCastle = false;
            break;
          }
        }
        //If all these are true, the move is valid
        return canCastle;
      }
      return false;
    }
    return false;
  }

  static bool canCastleRight(ChessPosition position, ChessBoard board, ChessPiece myPiece) {
    if(!myPiece.hasMoved) {
      ChessPiece? rightHandRook = board.getPiece(ChessPosition(position.row, 7));
      if(rightHandRook != null && rightHandRook.color == myPiece.color && rightHandRook.type == ChessPieceType.rook && !rightHandRook.hasMoved) {
        ChessPosition tempPosition = ChessPosition(position.row, position.col);
        bool canCastle = true;
        while(tempPosition != ChessPosition(position.row, 6))  {
          tempPosition.col += 1;
          ChessPiece? piece = board.getPiece(tempPosition);
          if(piece != null) {
            canCastle = false;
            break;
          }
        }
        return canCastle;
      }
      return false;
    }
    return false;
  }
}