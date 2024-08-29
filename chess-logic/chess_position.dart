//A Class to represent a position on the chess board
class ChessPosition {
  //row of position
  int row;
  //column of position
  int col;

  ChessPosition(this.row, this.col);

  ChessPosition.fromStandardFormat(String stringVal):
    row = 7 - (int.parse(stringVal[1]) - 1),
    col = stringVal[0].codeUnits[0] - 97;

  String convertPosition() {
    String positionString = "";
    //converting our row numbering to standard chess numbering
    int tempRow = (row - 8).abs();
    String colLetter = String.fromCharCode(97 + col);
    positionString = colLetter + tempRow.toString();
    return positionString;
  }

  ChessPosition.fromJson(Map<String, dynamic> json):
      row = json['row'] as int,
      col = json['col'] as int;

  Map<String, dynamic> toJson() => {
    'row': row,
    'col': col
  };

  //Helper function to check if this position is in bounds of board.
  bool isInBounds() {
    if(row < 0 || row > 7 || col < 0 || col > 7) {
      return false;
    }
    return true;
  }

  //overridden equals operator so we can compare position
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChessPosition &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;
}