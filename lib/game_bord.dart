import 'package:chess/components/dead_piece.dart';
import 'package:chess/components/piece.dart';
import 'package:chess/components/square.dart';
import 'package:chess/values/colors.dart';
import 'package:flutter/material.dart';

class GameBord extends StatefulWidget {
  const GameBord({super.key});

  @override
  State<GameBord> createState() => _GameBordState();
}

class _GameBordState extends State<GameBord> {
  late List<List<ChessPiece?>> board;
  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedcol = -1;
  List<List<int>> validMoves = [];

  // List of white pieces that have been taken by the black player
  List<ChessPiece> whitePiecesTaken = [];

  // List of black pieces that have been taken by the white player
  List<ChessPiece> blackPiecesTaken = [];

  bool isWhiteTurn =true ;


  //inital position of kings
  List<int>whiteKingPosition = [7,4];
  List<int>blackKingPosition = [0,4];
  bool checkStatus=false ;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    // Place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
        type: ChessPieceType.pawn,
        imagePath: 'lib/images/pawn.png',
        isWhite: false,
      );
      newBoard[6][i] = ChessPiece(
        type: ChessPieceType.pawn,
        imagePath: 'lib/images/pawn.png',
        isWhite: true,
      );
    }

    // Place rooks
    newBoard[0][0] = ChessPiece(
      type: ChessPieceType.rook,
      imagePath: 'lib/images/rook.png',
      isWhite: false,
    );
    newBoard[0][7] = ChessPiece(
      type: ChessPieceType.rook,
      imagePath: 'lib/images/rook.png',
      isWhite: false,
    );
    newBoard[7][0] = ChessPiece(
      type: ChessPieceType.rook,
      imagePath: 'lib/images/rook.png',
      isWhite: true,
    );
    newBoard[7][7] = ChessPiece(
      type: ChessPieceType.rook,
      imagePath: 'lib/images/rook.png',
      isWhite: true,
    );

    // Place knights
    newBoard[0][1] = ChessPiece(
      type: ChessPieceType.kinght,
      imagePath: 'lib/images/knight.png',
      isWhite: false,
    );
    newBoard[0][6] = ChessPiece(
      type: ChessPieceType.kinght,
      imagePath: 'lib/images/knight.png',
      isWhite: false,
    );
    newBoard[7][1] = ChessPiece(
      type: ChessPieceType.kinght,
      imagePath: 'lib/images/knight.png',
      isWhite: true,
    );
    newBoard[7][6] = ChessPiece(
      type: ChessPieceType.kinght,
      imagePath: 'lib/images/knight.png',
      isWhite: true,
    );

    // Place bishops
    newBoard[0][2] = ChessPiece(
      type: ChessPieceType.bishop,
      imagePath: 'lib/images/bishop.png',
      isWhite: false,
    );
    newBoard[0][5] = ChessPiece(
      type: ChessPieceType.bishop,
      imagePath: 'lib/images/bishop.png',
      isWhite: false,
    );
    newBoard[7][2] = ChessPiece(
      type: ChessPieceType.bishop,
      imagePath: 'lib/images/bishop.png',
      isWhite: true,
    );
    newBoard[7][5] = ChessPiece(
      type: ChessPieceType.bishop,
      imagePath: 'lib/images/bishop.png',
      isWhite: true,
    );

    // Place queens
    newBoard[0][3] = ChessPiece(
      type: ChessPieceType.queen,
      imagePath: 'lib/images/queen.png',
      isWhite: false,
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.queen,
      imagePath: 'lib/images/queen.png',
      isWhite: true,
    );

    // Place kings
    newBoard[0][4] = ChessPiece(
      type: ChessPieceType.king,
      imagePath: 'lib/images/king.png',
      isWhite: false,
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieceType.king,
      imagePath: 'lib/images/king.png',
      isWhite: true,
    );

    board = newBoard;
  }

  void pieceSelected(int row, int col) {
    setState(() {
      if (selectedPiece == null && board[row][col] != null) {
        if(board[row][col]!.isWhite == isWhiteTurn){
          selectedPiece = board[row][col];
        selectedRow = row;
        selectedcol = col;
        }
      } 
      else if (board[row][col] != null &&
          board[row][col]!.isWhite == selectedPiece!.isWhite) {
        selectedPiece = board[row][col];
        selectedRow = row;
        selectedcol = col;
      } else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      validMoves = calculateRawValidMoves(selectedRow, selectedcol, selectedPiece);
    });
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    if (piece == null) {
      return [];
    }

    int direction = piece.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        // Pawns can move forward
        if (isInBoard(row + direction, col) && board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }
        // Pawns can move 2 squares forward
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) &&
              board[row + 2 * direction][col] == null &&
              board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }
        // Pawns can capture diagonally
        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;
      case ChessPieceType.rook:
        // Horizontal and vertical directions
        var directions = [
          [-1, 0], // up
          [1, 0], // down
          [0, -1], // left
          [0, 1], // right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // capture
              }
              break; // blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.kinght:
        // All eight possible L shapes the knight can move
        var knightMoves = [
          [-2, -1],
          [-2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
          [2, -1],
          [2, 1],
        ];
        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      case ChessPieceType.bishop:
        // Diagonal directions
        var directions = [
          [-1, -1], // up left
          [-1, 1], // up right
          [1, -1], // down left
          [1, 1], // down right
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.queen:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];
        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]);
              }
              break;
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;
      case ChessPieceType.king:
        var directions = [
          [-1, 0],
          [1, 0],
          [0, -1],
          [0, 1],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];
        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]);
            }
            continue;
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
      default:
    }
    return candidateMoves;
  }

  void movePiece(int newRow, int newCol) {
    // if the new spot has an enemy piece
    if (board[newRow][newCol] != null) {
      // add the captured piece to the appropriate list
      var capturedPiece = board[newRow][newCol];
      if (capturedPiece!.isWhite) {
        whitePiecesTaken.add(capturedPiece);
      } else {
        blackPiecesTaken.add(capturedPiece);
      }
    }

    // move the piece and clear the old spot
    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedcol] = null;

    // see if any kinge are under attcak
    if(isKingIncheck(!isWhiteTurn)){
      checkStatus=true;
    }else{
      checkStatus=false ;
    }

    setState(() {
      selectedPiece = null;
      selectedRow = 1;
      selectedcol = -1;
      validMoves = [];
    });

    //change turns 
    isWhiteTurn=!isWhiteTurn ;
  }
  
  //is King in check

  bool isKingIncheck (bool isWhiteKing){
    //get the psition king
    List<int> KingPosition = 
    isWhiteKing ? whiteKingPosition : blackKingPosition ;

    //check if any eneme piece can attack the king
    for(int i=0; i< 8; i++){
      for(int j=0; j <8; j++){
        //skip empty squares and piecs of the sam color as the king 
        if(board[i][j]== null || board[i][j]!.isWhite == isWhiteKing){
          continue ;
        }
        List<List<int>>pieceValidMoves=
        calculateRawValidMoves(i, j, board[i][j]);
        //check the king postion
        if(pieceValidMoves.any((move)=>
        move[0] == KingPosition[0]&& move[1]==KingPosition[1])){
          return true ;
        }
      }
    }
    return false ;
  }


  bool isInBoard(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  bool isWhite(int index) {
    int row = index ~/ 8;
    int col = index % 8;
    return (row + col) % 2 == 0;

    
  }

  void resetGame(){
    Navigator.pop(context);
    _initializeBoard();
    checkStatus=false ;
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    whiteKingPosition=[7,4];
    blackKingPosition=[0,4];
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // White pieces taken
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemCount: whitePiecesTaken.length,
            ),
          ),
          //Game over 
          Text(checkStatus ?"Game over": ""),
          // Chess Board
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder: (context, index) {
                int row = index ~/ 8;
                int col = index % 8;
                bool isSelected = selectedRow == row && selectedcol == col;
                bool isValidMove = false;
                for (var position in validMoves) {
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                  }
                }

                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: () => pieceSelected(row, col),
                );
              },
            ),
          ),
          // black pieces taken
          Expanded(
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: blackPiecesTaken[index].imagePath,
                isWhite: false,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemCount: blackPiecesTaken.length,
            ),
          ),
        ],
      ),
    );
  }
}
