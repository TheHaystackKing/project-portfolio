import 'chess_move.dart';
import 'chess_position.dart';
import 'move_calculators/bishop_calculator.dart';
import 'move_calculators/king_calculator.dart';
import 'move_calculators/knight_calculator.dart';
import 'move_calculators/rook_calculator.dart';

class ChessBoard {
  late List<List<ChessPiece?>> board;
  List<ChessMove> moveList = [];
  bool userTurn = true;
  bool userCheck = false;
  bool opponentCheck = false;
  bool checkStatus = false;
  bool gameEnd = false;
  bool isCheckmate = false;
  bool isPromotion = false;
  bool automatedMoves = false;
  bool aiThinking = false;
  String gameEndMessage = '';
  ChessMove? promotionMove;
  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;
  Set<ChessMove> validMoves = {};
  List<ChessPiece> whitePiecesCaptured = [];
  List<ChessPiece> blackPiecesCaptured = [];
  List<ChessPosition> enPassantTargets = [];
  int halfMoveClock = 0;
  int fullMoveClock = 1;
  late ChessUtils utils;

  //Default Constructor
  ChessBoard() {
    initializeBoard();
  }

  //Alternate constructor that leaves board empty, doesn't initialize utility functions
  ChessBoard.emptyBoard() {
    board = List.generate(8, (index) => List.generate(8, (index) => null));
  }

  //Function that clears board
  void emptyBoard() {
    board = List.generate(8, (index) => List.generate(8, (index) => null));
  }

  //takes the board from another game and can clones it this game
  void cloneBoard(ChessBoard game) {
    for(int i = 0; i < 8; ++i) {
      for(int j = 0; j < 8; ++j) {
        board[i][j] = game.board[i][j];
      }
    }
  }

  //Adds a piece to the board at a given position
  void addPiece(ChessPiece? piece, ChessPosition position) {
    board[position.row][position.col] = piece;
  }

  //Get the piece at this board position
  ChessPiece? getPiece(ChessPosition position) {
    return board[position.row][position.col];
  }

  //Moves the chess piece and does some actions related to the move
  void movePiece(ChessMove move) {
    //Makes the move described by this move, add it to move list
    ChessPosition newPosition = move.endPosition;
    ChessPosition selectedPosition = move.startPosition;
    addPiece(move.myPiece, newPosition);
    addPiece(null, selectedPosition);
    moveList.add(move);

    //If move was not a capture or a pawn move, increment half-move clock, otherwise reset to 0
    if(move.capturedPiece == null || move.myPiece.type != ChessPieceType.pawn) {
      halfMoveClock++;
    }
    else {
      halfMoveClock = 0;
    }

    //if the move is a double pawn move, add to en-passant targets list (used for FEN string)
    if(move.myPiece.type == ChessPieceType.pawn && (move.endPosition.row - move.startPosition.row).abs() == 2) {
      if(move.myPiece.color == TeamColor.white) {
        enPassantTargets.add(ChessPosition(move.endPosition.row + 1, move.endPosition.col));
      }
      else {
        enPassantTargets.add(ChessPosition(move.endPosition.row - 1, move.endPosition.col));
      }
    }

    //check the en passant target list to see if any of the pawns have move or been captured, and removes them from the list
    List<ChessPosition> toRemove = [];
    for(ChessPosition position in enPassantTargets) {
      if(position.row == 5) {
        ChessPiece? piece = getPiece(ChessPosition(4, position.col));
        if((piece != null && (piece.color != TeamColor.white || piece.type != ChessPieceType.pawn)) || piece == null) {
          toRemove.add(position);
        }
      }
      if(position.row == 2) {
        ChessPiece? piece = getPiece(ChessPosition(3, position.col));
        if((piece != null && (piece.color != TeamColor.black || piece.type != ChessPieceType.pawn)) || piece == null) {
          toRemove.add(position);
        }
      }
    }
    for(ChessPosition position in toRemove) {
      enPassantTargets.remove(position);
    }

    //function that manages additional moves required for special cases.
    specialCases();

    //Mark that the piece that just moved has moved (important for castling)
    getPiece(newPosition)?.hasMoved = true;
  }

  //Performs all of the logic involved for making a move
  void makeMove(ChessMove move) {
    //Actually make the move
    movePiece(move);

    // what color is the current team?
    TeamColor color;
    TeamColor opponent;
    if (userTurn) {
      color = TeamColor.white;
      opponent = TeamColor.black;
    }
    else {
      color = TeamColor.black;
      opponent = TeamColor.white;
    }

    //Is the king in check
    userCheck = isInCheck(opponent);
    opponentCheck = isInCheck(color);

    //Set check status
    if (userCheck || opponentCheck) {
      checkStatus = true;
      moveList.last.promotion = ChessPieceType.check;
    }
    else {
      checkStatus = false;
    }

    //Reset selected pieces and positions
    selectedPiece = null;
    selectedRow = -1;
    selectedCol = -1;
    validMoves.clear();

    bool isStalemate = false;

    //Check for checkmate or stalemate
    if(isInCheckmate(opponent)) {
      isCheckmate = true;
      gameEndMessage = "CHECK MATE!";
      moveList.last.promotion = ChessPieceType.checkmate;
    }
    if(isInStalemate(opponent)) {
      isStalemate = true;
      gameEndMessage = "STALEMATE!";
    }

    // is it checkmate?
    if (isCheckmate || isStalemate) {
      gameEnd = true;
    }

    // change whose turn it is
    userTurn = !userTurn;
    if(userTurn) {
      fullMoveClock++;
    }
  }

  //Add Chess AI to chess utils
  void addChessAI(ChessAI chessAI) {
    utils.addChessAI(chessAI);
    automatedMoves = true;
  }

  //Make move as AI
  void aiMakeMove() async{
    //Set variable to block user board interaction while AI is making move
    aiThinking = true;

    //Load board state into AI, AI returns move string, which we convert into a move
    utils.chessAI.loadFENString(generateFENString());
    String nextMove = await utils.chessAI.determineNextMove();
    ChessMove move = ChessMove.fromStandardFormat(nextMove);

    //If capture move, then update captured piece list, make move, and play sounds associated with move
    move.myPiece = getPiece(move.startPosition)!;
    ChessPiece? capturedPiece = getPiece(move.endPosition);
    if(capturedPiece != null) {
      whitePiecesCaptured.add(capturedPiece);
    }
    makeMove(move);
    aiThinking = false;
  }

  //Generate the FEN (Forsyth-Edwards Notation) string, which the AI uses to know the board state
  String generateFENString() {
    String fen = "";
    //Convert board positions to string
    fen += toString();

    //add character for whose turn it is
    if(userTurn) {
      fen += " w";
    }
    else {
      fen += " b";
    }
    fen += " ";
    //add castling rights (has king/rook combo both not moved yet)
    ChessPiece? whiteKing = getPiece(ChessPosition(7, 4));
    ChessPiece? blackKing = getPiece(ChessPosition(0, 4));
    bool castleIncluded = false;
    if(whiteKing != null) {
      ChessPiece? leftHandRook = getPiece(ChessPosition(7, 0));
      ChessPiece? rightHandRook = getPiece(ChessPosition(7, 7));
      if(leftHandRook != null && !leftHandRook.hasMoved && !whiteKing.hasMoved) {
        fen += "K";
        castleIncluded = true;
      }
      if(rightHandRook != null && !rightHandRook.hasMoved && !whiteKing.hasMoved) {
        fen += "Q";
        castleIncluded = true;
      }
    }
    if(blackKing != null) {
      ChessPiece? leftHandRook = getPiece(ChessPosition(0, 0));
      ChessPiece? rightHandRook = getPiece(ChessPosition(0, 7));
      if(leftHandRook != null && !leftHandRook.hasMoved && !blackKing.hasMoved) {
        fen += "k";
        castleIncluded = true;
      }
      if(rightHandRook != null && !rightHandRook.hasMoved && !blackKing.hasMoved) {
        fen += "q";
        castleIncluded = true;
      }
    }
    if(!castleIncluded) {
      fen += "-";
    }
    fen += " ";

    //Add any en passant targets
    if(enPassantTargets.length > 0) {
      for(ChessPosition position in enPassantTargets) {
        fen += position.convertPosition();
      }
    }
    else {
      fen += "-";
    }
    //Add half-moves (non-capture/pawn movement) and total moves in game.
    fen += " $halfMoveClock $fullMoveClock";
    return fen;
  }

  void specialCases() {
    //get the move we have just made from list (needed for special cases)
    ChessMove currMove = moveList.last;

    if(currMove.promotion != null) {
      switch (currMove.promotion) {
        //Castling Logic
        case ChessPieceType.castle:
          //If king is on left-hand side of board, move rock to right of king
          if(currMove.endPosition.col == 2) {
            ChessPiece? piece = getPiece(ChessPosition(currMove.endPosition.row, 0));
            addPiece(piece, ChessPosition(currMove.endPosition.row, currMove.endPosition.col + 1));
            addPiece(null, ChessPosition(currMove.endPosition.row, 0));
          }
          //If king is on right-hand side of board, move rock to left of king
          else if(currMove.endPosition.col == 6) {
            ChessPiece? piece = getPiece(ChessPosition(currMove.endPosition.row, 7));
            addPiece(piece, ChessPosition(currMove.endPosition.row, currMove.endPosition.col - 1));
            addPiece(null, ChessPosition(currMove.endPosition.row, 7));
          }
          break;
        //En Passant Logic
        case ChessPieceType.enPassant:
          //If piece is white, remove piece one row below pawns new position
          if(currMove.myPiece.color == TeamColor.white) {
            addPiece(null, ChessPosition(currMove.endPosition.row + 1,currMove.endPosition.col));
            ChessPiece? target = currMove.capturedPiece;
            if(target != null) {
              blackPiecesCaptured.add(target);
            }
          }
          //If piece is black, remove piece one row above pawns new position
          if(currMove.myPiece.color == TeamColor.black) {
            addPiece(null, ChessPosition(currMove.endPosition.row - 1,currMove.endPosition.col));
            ChessPiece? target = currMove.capturedPiece;
            if(target != null) {
              whitePiecesCaptured.add(target);
            }
          }
          break;
        //Check and checkmate use the promotion variable, but we don't want to do anything with it, so we skip these cases
        case ChessPieceType.check:
          break;
        case ChessPieceType.checkmate:
          break;
        //All other cases are promotions, which set variables to have promotion dialog pop-up on screen.
        default:
          //If the AI or a unit test is making the move, replace the piece with its promotion
          if(automatedMoves) {
            ChessPiece currentPiece = currMove.myPiece;
            ChessPiece newPiece = ChessPiece(type: currMove.promotion!, color: currentPiece.color, imagePath: ChessPiece.getImagePath(currMove.promotion!));
            addPiece(newPiece, currMove.endPosition);
          }
          //If a player is making the move, set variables to pop a promotion dialog to have them choose their piece
          else {
            isPromotion = true;
            promotionMove = currMove;
          }
          break;
      }
    }


  }

  //Get the list of moves a piece can make at this position, disregarding check
  Set<ChessMove> pieceMoves(ChessPosition position) {
    ChessPiece? piece = getPiece(position);
    if(piece == null) {
      return {};
    }
    switch(piece.type) {
      case (ChessPieceType.rook):
        return RookCalculator.pieceMoves(position, this);
      case (ChessPieceType.bishop):
        return BishopCalculator.pieceMoves(position, this);
      case (ChessPieceType.queen):
        Set<ChessMove> comboList = {};
        comboList.addAll(RookCalculator.pieceMoves(position, this));
        comboList.addAll(BishopCalculator.pieceMoves(position, this));
        return comboList;
      case (ChessPieceType.knight):
        return KnightCalculator.pieceMoves(position, this);
      case (ChessPieceType.pawn):
        return PawnCalculator.pieceMoves(position, this, moveList);
      case (ChessPieceType.king):
        return KingCalculator.pieceMoves(position, this);
      default:
        return {};
    }
  }

  //Generate all the valid moves a piece at this particular position
  Set<ChessMove> validMovesGen(ChessPosition startPosition) {
    Set<ChessMove> validList = {};
    Set<ChessMove> potentialMoves = pieceMoves(startPosition);
    TeamColor color;
    ChessPiece? piece = getPiece(startPosition);
    if(piece != null) {
      color = piece.color;
      for(ChessMove move in potentialMoves) {
        //copy the board and make the move, see if you are in check, if not add it
        ChessBoard copy = ChessBoard.emptyBoard();
        copy.cloneBoard(this);
        copy.movePiece(move);
        if(!copy.isInCheck(color)) {
          validList.add(move);
        }
      }
    }
    return validList;
  }

  //Check if a certain team is check.
  bool isInCheck(TeamColor color) {
    //Iterate over the board, check piece moves of opposing piece
    for(int i = 0; i < 8; ++i) {
      for(int j = 0; j < 8; ++j) {
        ChessPosition position = ChessPosition(i, j);
        ChessPiece? piece = board[i][j];
        if(piece != null && piece.color != color) {
          Set<ChessMove> possibleMoveList = pieceMoves(position);
          for(ChessMove move in possibleMoveList) {
            ChessPiece? endPiece = getPiece(move.endPosition);
            //If end position of move has target teams king, is in check
            if(endPiece != null && endPiece.color == color && endPiece.type == ChessPieceType.king) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  //Check if a certain team is in checkmate
  bool isInCheckmate(TeamColor color) {
    //If you are not in check, you are not in checkmate
    if(!isInCheck(color)) {
      return false;
    }
    //Iterate over board, check all pieces of target team,
    //if any of them can get you out of check, you are not in checkmate.
    for(int i = 0; i < 8; ++i) {
      for(int j = 0; j < 8; ++j) {
        ChessPosition position = ChessPosition(i, j);
        ChessPiece? piece = board[i][j];
        if(piece != null && piece.color == color) {
          Set<ChessMove> validMoves = validMovesGen(position);
          if(validMoves.isNotEmpty) {
            return false;
          }
        }
      }
    }
    return true;
  }

  //Check if a certain team is in stalemate
  bool isInStalemate(TeamColor color) {
    //If 50 moves have been made without progression (capture or pawn movement), is stalemate
    if(halfMoveClock >= 50) {
      return true;
    }
    //If you are in check, you are not in stalemate
    if(isInCheck(color)) {
      return false;
    }
    //Iterate over board, check all pieces of target team,
    bool otherWhitePiece = false;
    bool otherBlackPiece = false;
    bool isStalemate = true;
    for(int i = 0; i < 8; ++i) {
      for(int j = 0; j < 8; ++j) {
        ChessPosition position = ChessPosition(i, j);
        ChessPiece? piece = board[i][j];
        //If any piece can make a move that would not put you in check, not in stalemate
        if(piece != null && piece.color == color) {
          Set<ChessMove> validMoves = validMovesGen(position);
          if(validMoves.isNotEmpty) {
            isStalemate = false;
          }
        }
        //If there is a piece other than the king on the board, mark variable
        if(piece != null && piece.type != ChessPieceType.king) {
          if(piece.color == TeamColor.white) {
            otherWhitePiece = true;
          }
          else {
            otherBlackPiece = true;
          }
        }
      }
    }

    //If only king left on both sides, is stalemate
    if(otherBlackPiece == false && otherWhitePiece == false) {
      isStalemate = true;
    }
    return isStalemate;
  }

  //Used to print board string for FEN string, prints upper/lowercase letter for each piece, with numbers representing the number of empty spaces between.
  @override
  String toString() {
    String boardString = "";
    for(int i = 0; i < 8; ++i) {
      int emptySpaces = 0;
      for(int j = 0; j < 8; ++j) {
        ChessPiece? piece = getPiece(ChessPosition(i, j));
        if(piece == null) {
          emptySpaces++;
        }
        else {
          if(emptySpaces > 0) {
            boardString += emptySpaces.toString();
            emptySpaces = 0;
          }
          boardString += piece.getCharFromPiece();
        }
      }
      if(emptySpaces > 0) {
        boardString += emptySpaces.toString();
        emptySpaces = 0;
      }
      if(i != 7) {
        boardString += "/";
      }
    }
    return boardString;
  }

  void initializeBoard() {
    // start with blank board
    List<List<ChessPiece?>> newBoard =
    List.generate(8, (index) => List.generate(8, (index) => null));

    // pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
          type: ChessPieceType.pawn,
          color: TeamColor.black,
          imagePath: 'lib/assets/pieces/pawn.png'
      );
      newBoard[6][i] = ChessPiece(
          type: ChessPieceType.pawn,
          color: TeamColor.white,
          imagePath: 'lib/assets/pieces/pawn.png'
      );
    }

    // rooks
    newBoard[0][0] = ChessPiece(
        type: ChessPieceType.rook,
        color: TeamColor.black,
        imagePath: 'lib/assets/pieces/rook.png'
    );
    newBoard[0][7] = ChessPiece(
        type: ChessPieceType.rook,
        color: TeamColor.black,
        imagePath: 'lib/assets/pieces/rook.png'
    );
    newBoard[7][7] = ChessPiece(
        type: ChessPieceType.rook,
        color: TeamColor.white,
        imagePath: 'lib/assets/pieces/rook.png'
    );
    newBoard[7][0] = ChessPiece(
        type: ChessPieceType.rook,
        color: TeamColor.white,
        imagePath: 'lib/assets/pieces/rook.png'
    );

    // knights
    newBoard[0][1] = ChessPiece(
        type: ChessPieceType.knight,
        color: TeamColor.black,
        imagePath: 'lib/assets/pieces/knight.png'
    );
    newBoard[0][6] = ChessPiece(
        type: ChessPieceType.knight,
        color: TeamColor.black,
        imagePath: 'lib/assets/pieces/knight.png'
    );
    newBoard[7][1] = ChessPiece(
        type: ChessPieceType.knight,
        color: TeamColor.white,
        imagePath: 'lib/assets/pieces/knight.png'
    );
    newBoard[7][6] = ChessPiece(
        type: ChessPieceType.knight,
        color: TeamColor.white,
        imagePath: 'lib/assets/pieces/knight.png'
    );

    // bishops
    newBoard[0][2] = ChessPiece(
        type: ChessPieceType.bishop,
        color: TeamColor.black,
        imagePath: 'lib/assets/pieces/bishop.png'
    );
    newBoard[0][5] = ChessPiece(
        type: ChessPieceType.bishop,
        color: TeamColor.black,
        imagePath: 'lib/assets/pieces/bishop.png'
    );
    newBoard[7][2] = ChessPiece(
        type: ChessPieceType.bishop,
        color: TeamColor.white,
        imagePath: 'lib/assets/pieces/bishop.png'
    );
    newBoard[7][5] = ChessPiece(
        type: ChessPieceType.bishop,
        color: TeamColor.white,
        imagePath: 'lib/assets/pieces/bishop.png'
    );

    // queens
    newBoard[0][3] = ChessPiece(
        type: ChessPieceType.queen,
        color: TeamColor.black,
        imagePath: 'lib/assets/pieces/queen.png'
    );
    newBoard[7][3] = ChessPiece(
        type: ChessPieceType.queen,
        color: TeamColor.white,
        imagePath: 'lib/assets/pieces/queen.png'
    );

    // kings
    newBoard[0][4] = ChessPiece(
        type: ChessPieceType.king,
        color: TeamColor.black,
        imagePath: 'lib/assets/pieces/king.png'
    );
    newBoard[7][4] = ChessPiece(
        type: ChessPieceType.king,
        color: TeamColor.white,
        imagePath: 'lib/assets/pieces/king.png'
    );

    board = newBoard;
  }
}