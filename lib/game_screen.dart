import 'package:flutter/material.dart';
import 'game_state.dart';
import 'package:collection/collection.dart'; // For firstWhereOrNull

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState _gameState;
  Character? _selectedCharacter;
  List<Position> _possibleMoves = [];

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    // Initialize characters and game state
    _gameState = GameState(
      player1Characters: [
        Character(type: CharacterType.Pawn, isPlayer1: true, x: 0, y: 0),
        Character(type: CharacterType.Hero1, isPlayer1: true, x: 0, y: 1),
        Character(type: CharacterType.Hero2, isPlayer1: true, x: 0, y: 2),
        Character(type: CharacterType.Pawn, isPlayer1: true, x: 0, y: 3),
        Character(type: CharacterType.Pawn, isPlayer1: true, x: 0, y: 4),
      ],
      player2Characters: [
        Character(type: CharacterType.Pawn, isPlayer1: false, x: 4, y: 0),
        Character(type: CharacterType.Hero1, isPlayer1: false, x: 4, y: 1),
        Character(type: CharacterType.Hero2, isPlayer1: false, x: 4, y: 2),
        Character(type: CharacterType.Pawn, isPlayer1: false, x: 4, y: 3),
        Character(type: CharacterType.Pawn, isPlayer1: false, x: 4, y: 4),
      ],
    );
  }

  void _handleCellTap(int x, int y) {
    if (_selectedCharacter == null) {
      // Select character if there is one on the tapped cell
      Character? character = _findCharacterAt(x, y);
      if (character != null &&
          character.isPlayer1 == _gameState.isPlayer1Turn) {
        setState(() {
          _selectedCharacter = character;
          _possibleMoves = _gameState.getPossibleMoves(character);
        });
      }
    } else {
      // Move the selected character
      if (_possibleMoves.any((pos) => pos.x == x && pos.y == y)) {
        try {
          _gameState.moveCharacter(_selectedCharacter!, x, y);
          setState(() {
            _selectedCharacter = null;
            _possibleMoves.clear();
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid move: ${e.toString()}')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Move not allowed')),
        );
      }
    }

    if (_gameState.isGameOver()) {
      _showGameOverDialog();
    }
  }

  Character? _findCharacterAt(int x, int y) {
    return _gameState.player1Characters
            .firstWhereOrNull((c) => c.x == x && c.y == y) ??
        _gameState.player2Characters
            .firstWhereOrNull((c) => c.x == x && c.y == y);
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Game Over',style: TextStyle(fontWeight: FontWeight.bold),),
          content: Text(_gameState.player1Characters.isEmpty
              ? 'Player 2 Wins!'
              : 'Player 1 Wins!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _initializeGame();
                setState(() {});
              },
              child: Text('Restart',style: TextStyle(fontWeight: FontWeight.bold),),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Offline Game',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Text(
            "Rules",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
              onPressed: () {
                showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return Container(
                      height: 250,
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            SizedBox(
                              height: 20,
                            ),
                            const Text(
                              '  Rules',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text("  Once Selected Must Move"),
                            SizedBox(
                              height: 10,
                            ),
                            Text("  P Moves 1 Block in Any Direction"),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                                overflow: TextOverflow.clip,
                                "  H1 Moves 1 or 2 Block in Any Direction"),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              overflow: TextOverflow.clip,
                                "  H2 Moves 1 or 2 Block in Any Direction Diagonally"),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              icon: Icon(Icons.rule_folder_rounded)),
          SizedBox(
            width: 10,
          ),
        ],
      ),
      body: ListView(
        children: [
          // Whose move it is
          Container(
            height: 80,
            width: double.infinity,
            color: Color(0xFF95bfbd),
            padding: EdgeInsets.all(16),
            child: Center(
              child: Text(
                _gameState.isPlayer1Turn
                    ? 'Player 1\'s Move'
                    : 'Player 2\'s Move',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: SizedBox(
                  //height: MediaQuery.of(context).size.height - 180,
                  width: MediaQuery.of(context).size.width - 30,
                  child: GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                    ),
                    itemBuilder: (context, index) {
                      int x = index % 5;
                      int y = index ~/ 5;

                      return GestureDetector(
                        onTap: () => _handleCellTap(x, y),
                        child: Container(
                          color: _getCellColor(x, y),
                          child: Center(
                            child: _buildCellContent(x, y),
                          ),
                        ),
                      );
                    },
                    itemCount: 25,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getCellColor(int x, int y) {
    // Highlight cells for possible moves
    if (_possibleMoves.any((pos) => pos.x == x && pos.y == y)) {
      Character? character = _findCharacterAt(x, y);
      if (character != null) {
        // Cell is occupied by an opponent
        return Colors.red[800]!; // Dark red for opponent characters
      }
      return Colors.green.withOpacity(0.5); // Highlight possible move cells
    }
    // Default cell color
    return (x + y) % 2 == 0 ? Color(0xFF95bfbd)! : Colors.grey[100]!;
  }

  Widget _buildCellContent(int x, int y) {
    Character? character = _findCharacterAt(x, y);
    if (character != null) {
      return Text(
        _getCharacterLabel(character),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: _selectedCharacter == character ? Colors.blue : Colors.black,
        ),
      );
    }
    return SizedBox.shrink();
  }

  String _getCharacterLabel(Character character) {
    String playerLabel = character.isPlayer1 ? 'P1' : 'P2';
    switch (character.type) {
      case CharacterType.Pawn:
        return '$playerLabel P';
      case CharacterType.Hero1:
        return '$playerLabel H1';
      case CharacterType.Hero2:
        return '$playerLabel H2';
      default:
        return '';
    }
  }
}
