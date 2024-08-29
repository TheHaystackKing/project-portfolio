import 'dart:math';

enum ChessPieceType {pawn, rook, bishop, knight, king, queen, castle, enPassant, check, checkmate}
enum TeamColor {white, black}

class ChessPiece {
  final ChessPieceType type;
  final TeamColor color;
  String imagePath;
  bool hasMoved = false;

  ChessPiece({
    required this.type,
    required this.color,
    required this.imagePath
  });

  ChessPiece.fromJson(Map<String, dynamic> json):
    type = stringToPieceType(json['type']),
    color = stringToTeamColor(json['color']),
    imagePath = json['imagePath'] as String,
    hasMoved = json['hasMoved'] as bool;

  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'color': color.toString(),
    'imagePath': imagePath,
    'hasMoved': hasMoved
  };

  static ChessPieceType stringToPieceType(String typeString) {
    if(typeString == "ChessPieceType.pawn") {
      return ChessPieceType.pawn;
    }
    else if(typeString == "ChessPieceType.rook") {
      return ChessPieceType.rook;
    }
    else if(typeString == "ChessPieceType.bishop") {
      return ChessPieceType.bishop;
    }
    else if(typeString == "ChessPieceType.knight") {
      return ChessPieceType.knight;
    }
    else if(typeString == "ChessPieceType.queen") {
      return ChessPieceType.queen;
    }
    else if(typeString == "ChessPieceType.king") {
      return ChessPieceType.king;
    }
    else {
      return ChessPieceType.castle;
    }
  }

  static TeamColor stringToTeamColor(String colorString) {
    if(colorString == "TeamColor.black") {
      return TeamColor.black;
    }
    else {
      return TeamColor.white;
    }
  }

  static String getImagePath(ChessPieceType type) {
    switch(type) {
      case (ChessPieceType.rook):
        return 'lib/assets/pieces/rook.png';
      case (ChessPieceType.bishop):
        return 'lib/assets/pieces/bishop.png';
      case (ChessPieceType.queen):
        return 'lib/assets/pieces/queen.png';
      case (ChessPieceType.knight):
        return 'lib/assets/pieces/knight.png';
      case (ChessPieceType.pawn):
        return 'lib/assets/pieces/pawn.png';
      case (ChessPieceType.king):
        return 'lib/assets/pieces/king.png';
      default:
        return "";
    }
  }

  String getCharFromPiece() {
    String piece = "";
    switch(type) {
      case (ChessPieceType.rook):
        piece = "r";
      case (ChessPieceType.bishop):
        piece = "b";
      case (ChessPieceType.queen):
        piece = "q";
      case (ChessPieceType.knight):
        piece = "n";
      case (ChessPieceType.pawn):
        piece = "p";
      case (ChessPieceType.king):
        piece = "k";
      default:
        return "";
    }
    if(color == TeamColor.white) {
      piece = piece.toUpperCase();
    }
    return piece;
  }

  @override
  String toString() {
    return 'ChessPiece{type: $type, color: $color, imagePath: $imagePath}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChessPiece &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          color == other.color &&
          imagePath == other.imagePath;

  @override
  int get hashCode => type.hashCode ^ color.hashCode ^ imagePath.hashCode;

  String getName() {
    String pieceName = "";
    if(color == TeamColor.white) {
      pieceName += "white";
    }
    else {
      pieceName += "black";
    }
    pieceName += "-";

    switch(type) {
      case (ChessPieceType.rook):
        pieceName += 'rook';
      case (ChessPieceType.bishop):
        pieceName += 'bishop';
      case (ChessPieceType.queen):
        pieceName += 'queen';
      case (ChessPieceType.knight):
        pieceName += 'knight';
      case (ChessPieceType.pawn):
        pieceName += 'pawn';
      case (ChessPieceType.king):
        pieceName += 'king';
      default:
        pieceName += "";
    }

    return pieceName;
  }
}