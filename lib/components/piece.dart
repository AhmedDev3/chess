enum ChessPieceType { pawn , rook , kinght , bishop , queen , king }

class ChessPiece{
  final ChessPieceType type ;
  final bool isWhite;
  final String imagePath ;
  
  ChessPiece({
    required this.type,
    required this.imagePath,
    required this.isWhite
     });

}