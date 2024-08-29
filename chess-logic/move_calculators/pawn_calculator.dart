import '../chess_move.dart';
import '../chess_position.dart';
import '../piece.dart';

class PawnCalculator {
  static Set<ChessMove> pieceMoves(ChessPosition position, ChessBoard board, List<ChessMove> moveList) {
    Set<ChessMove> potentialMoves = {};
    ChessPiece? myPiece = board.getPiece(position);
    if(myPiece == null) {
      return potentialMoves;
    }
    int direction;
    if(myPiece.color == TeamColor.white) {
      direction = -1;
    }
    else {
      direction = 1;
    }
    //Single Move Forward
    ChessPosition newPosition = ChessPosition(position.row + direction, position.col);
    if(newPosition.isInBounds()) {
      ChessPiece? piece = board.getPiece(newPosition);
      if(piece == null) {
        if((myPiece.color == TeamColor.white && newPosition.row == 0) || (myPiece.color == TeamColor.black && newPosition.row == 7)) {
          potentialMoves.add(ChessMove(position, newPosition, ChessPieceType.knight, null, myPiece));
          potentialMoves.add(ChessMove(position, newPosition, ChessPieceType.rook, null, myPiece));
          potentialMoves.add(ChessMove(position, newPosition, ChessPieceType.bishop, null, myPiece));
          potentialMoves.add(ChessMove(position, newPosition, ChessPieceType.queen, null, myPiece));
        }
        else {
          potentialMoves.add(ChessMove(position, newPosition, null, null, myPiece));
        }
      }
    }

    //Double Move Forward
    if((myPiece.color == TeamColor.white && position.row == 6) || (myPiece.color == TeamColor.black && position.row == 1)) {
      newPosition = ChessPosition(position.row + direction, position.col);
      if(newPosition.isInBounds()) {
        ChessPiece? piece = board.getPiece(newPosition);
        if(piece == null) {
          newPosition = ChessPosition(position.row + (direction * 2), position.col);
          if(newPosition.isInBounds()) {
            ChessPiece? piece = board.getPiece(newPosition);
            if(piece == null) {
              if((myPiece.color == TeamColor.white && newPosition.row == 0) || (myPiece.color == TeamColor.black && newPosition.row == 7)) {
                potentialMoves.add(ChessMove(position, newPosition, ChessPieceType.knight, null, myPiece));
                potentialMoves.add(ChessMove(position, newPosition, ChessPieceType.rook, null, myPiece));
                potentialMoves.add(ChessMove(position, newPosition, ChessPieceType.bishop, null, myPiece));
                potentialMoves.add(ChessMove(position, newPosition, ChessPieceType.queen, null, myPiece));
              }
              else {
                potentialMoves.add(ChessMove(position, newPosition, null, null, myPiece));
              }
            }
          }
        }
      }
    }

    //Capture
    ChessPosition leftCapture = ChessPosition(position.row + direction, position.col - 1);
    ChessPosition rightCapture = ChessPosition(position.row + direction, position.col + 1);
    if(leftCapture.isInBounds()) {
      ChessPiece? piece = board.getPiece(leftCapture);
      if(piece != null && piece.color != myPiece.color) {
        if((myPiece.color == TeamColor.white && leftCapture.row == 0) || (myPiece.color == TeamColor.black && leftCapture.row == 7)) {
          potentialMoves.add(ChessMove(position, leftCapture, ChessPieceType.knight, piece, myPiece));
          potentialMoves.add(ChessMove(position, leftCapture, ChessPieceType.rook, piece, myPiece));
          potentialMoves.add(ChessMove(position, leftCapture, ChessPieceType.bishop, piece, myPiece));
          potentialMoves.add(ChessMove(position, leftCapture, ChessPieceType.queen, piece, myPiece));
        }
        else {
          potentialMoves.add(ChessMove(position, leftCapture, null, piece, myPiece));
        }
      }
    }
    if(rightCapture.isInBounds()) {
      ChessPiece? piece = board.getPiece(rightCapture);
      if(piece != null && piece.color != myPiece.color) {
        if((myPiece.color == TeamColor.white && rightCapture.row == 0) || (myPiece.color == TeamColor.black && rightCapture.row == 7)) {
          potentialMoves.add(ChessMove(position, rightCapture, ChessPieceType.knight, piece, myPiece));
          potentialMoves.add(ChessMove(position, rightCapture, ChessPieceType.rook, piece, myPiece));
          potentialMoves.add(ChessMove(position, rightCapture, ChessPieceType.bishop, piece, myPiece));
          potentialMoves.add(ChessMove(position, rightCapture, ChessPieceType.queen, piece, myPiece));
        }
        else {
          potentialMoves.add(ChessMove(position, rightCapture, null, piece, myPiece));
        }
      }
    }

    //En Passant
    ChessPosition enPassantLeft = ChessPosition(position.row, position.col - 1);
    ChessPosition enPassantRight = ChessPosition(position.row, position.col + 1);
    //End passant only applies if your opponent made a move
    if(moveList.isNotEmpty) {
      ChessMove prevMove = moveList.last;
      //Check if the square you will be moving to and the square with the enemy piece is are in bounds
      if(enPassantLeft.isInBounds() && leftCapture.isInBounds()) {
        ChessPiece? targetPiece = board.getPiece(enPassantLeft);
        //Check that a pawn of the opposite team is on the square directly to your left
        if(targetPiece != null && targetPiece.type == ChessPieceType.pawn && targetPiece.color != myPiece.color) {
          ChessPosition startPosition = ChessPosition(enPassantLeft.row + (direction * 2), enPassantLeft.col);
          //check that the previous move was a double move with the pawn you are targeting
          if(prevMove.endPosition == enPassantLeft && prevMove.startPosition == startPosition) {
            ChessPiece? targetLocation = board.getPiece(leftCapture);
            //Check that the square you will actually move to is empty.
            if(targetLocation == null) {
              //En passant is valid
              potentialMoves.add(ChessMove(position, leftCapture, ChessPieceType.enPassant, targetPiece, myPiece));
            }
          }
        }
      }

      //Same thing, but on the right
      if(enPassantRight.isInBounds() && rightCapture.isInBounds()) {
        ChessPiece? targetPiece = board.getPiece(enPassantRight);
        if(targetPiece != null && targetPiece.type == ChessPieceType.pawn && targetPiece.color != myPiece.color) {
          ChessPosition startPosition = ChessPosition(enPassantRight.row + (direction * 2), enPassantRight.col);
          if(prevMove.endPosition == enPassantRight && prevMove.startPosition == startPosition) {
            ChessPiece? targetLocation = board.getPiece(rightCapture);
            if(targetLocation == null) {
              potentialMoves.add(ChessMove(position, rightCapture, ChessPieceType.enPassant, targetPiece, myPiece));
            }
          }
        }
      }
    }

    return potentialMoves;
  }
}