import 'chess_position.dart';

class ChessMove {
  ChessPosition startPosition;
  ChessPosition endPosition;
  ChessPieceType? promotion; // Assuming ChessPieceType is an enum
  ChessPiece? capturedPiece;
  ChessPiece myPiece;

  ChessMove(this.startPosition, this.endPosition, this.promotion, this.capturedPiece, this.myPiece);

  ChessMove.fromStandardFormat(String stringVal):
    promotion = null,
    capturedPiece = null,
    myPiece = ChessPiece(type: ChessPieceType.pawn, color: TeamColor.black, imagePath: ''),
    startPosition = ChessPosition.fromStandardFormat(stringVal.substring(0, 2)),
    endPosition = ChessPosition.fromStandardFormat(stringVal.substring(2, 4));

  String convertMove() {
    String moveString = "";
    moveString = "${startPosition.convertPosition()}${endPosition.convertPosition()}";
    return moveString;
  }

  ChessMove.fromJson(Map<String, dynamic> json)
      : startPosition = ChessPosition.fromJson(json['startPosition'] as Map<String, dynamic>),
        endPosition = ChessPosition.fromJson(json['endPosition'] as Map<String, dynamic>),
        promotion = json['promotion'] != null ? ChessPieceType.values.firstWhere((e) => e.toString().split('.').last == json['promotion']) : null,
        capturedPiece = json['capturedPiece'] != null ? ChessPiece.fromJson(json['capturedPiece'] as Map<String, dynamic>) : null,
        myPiece = ChessPiece.fromJson(json['myPiece'] as Map<String, dynamic>);

  Map<String, dynamic> toJson() => {
    'startPosition': startPosition.toJson(),
    'endPosition': endPosition.toJson(),
    'promotion': promotion?.toString().split('.').last, // Serialize enum as string
    'capturedPiece': capturedPiece?.toJson(), // Only include if not null
    'myPiece': myPiece.toJson(),
  };

  @override
  bool operator ==(Object other) => identical(this, other) || other is ChessMove && runtimeType == other.runtimeType && startPosition == other.startPosition && endPosition == other.endPosition && promotion == other.promotion && capturedPiece == other.capturedPiece && myPiece == other.myPiece;

  @override
  int get hashCode => startPosition.hashCode ^ endPosition.hashCode ^ promotion.hashCode ^ capturedPiece.hashCode ^ myPiece.hashCode;

  @override
  String toString() => 'ChessMove{(${startPosition.row},${startPosition.col}) --> (${endPosition.row},${endPosition.col}), promotion: $promotion, capturedPiece: $capturedPiece, myPiece: $myPiece}';

  bool isCapture() => capturedPiece != null;
}