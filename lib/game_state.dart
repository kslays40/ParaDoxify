import 'package:collection/collection.dart'; // For firstWhereOrNull

// Define the character types
enum CharacterType { Pawn, Hero1, Hero2 }

// Define a character class
class Character {
  final CharacterType type;
  bool isPlayer1; // true if character belongs to player 1, false otherwise
  int x, y; // Position on the grid

  Character({
    required this.type,
    required this.isPlayer1,
    required this.x,
    required this.y,
  });
}

// Define a helper class for representing a position
class Position {
  final int x, y;
  Position(this.x, this.y);
}

// Define the game state
class GameState {
  List<Character> player1Characters;
  List<Character> player2Characters;
  List<Character> player1LostCharacters;
  List<Character> player2LostCharacters;
  bool isPlayer1Turn;

  GameState({
    required this.player1Characters,
    required this.player2Characters,
    this.isPlayer1Turn = true,
  })  : player1LostCharacters = [],
        player2LostCharacters = [];

  // Get the list of opponent characters
  List<Character> get opponentCharacters {
    return isPlayer1Turn ? player2Characters : player1Characters;
  }

  // Get the list of friendly characters
  List<Character> get friendlyCharacters {
    return isPlayer1Turn ? player1Characters : player2Characters;
  }

  // Check if a move is valid
  bool isMoveValid(Character character, int newX, int newY) {
    // Check out-of-bounds
    if (newX < 0 || newX >= 5 || newY < 0 || newY >= 5) return false;

    // Check if the target cell is occupied by a friendly character
    if (friendlyCharacters.any((c) => c.x == newX && c.y == newY)) return false;

    // Check if the move is valid for the character type
    switch (character.type) {
      case CharacterType.Pawn:
        return (newX == character.x && (newY - character.y).abs() == 1) ||
            (newY == character.y && (newX - character.x).abs() == 1);
      case CharacterType.Hero1:
        return (newX == character.x && (newY - character.y).abs() <= 2) ||
            (newY == character.y && (newX - character.x).abs() <= 2);
      case CharacterType.Hero2:
        return (newX - character.x).abs() <= 2 && (newY - character.y).abs() <= 2 &&
            (newX - character.x).abs() == (newY - character.y).abs();
      default:
        return false;
    }
  }

  // Move a character
  void moveCharacter(Character character, int newX, int newY) {
    if (!isMoveValid(character, newX, newY)) throw Exception('Invalid Move');

    // Process combat if the target cell is occupied by an opponent
    _processCombat(character, newX, newY);

    // Move the character
    character.x = newX;
    character.y = newY;

    // End turn
    isPlayer1Turn = !isPlayer1Turn;
  }

  // Process combat: remove opponent characters in the path
  void _processCombat(Character character, int newX, int newY) {
    List<Character> opponents = opponentCharacters;

    switch (character.type) {
      case CharacterType.Pawn:
      // Remove opponent if the move lands on their cell
        opponents.removeWhere((c) => c.x == newX && c.y == newY);
        _updateLostCharacters(opponents, newX, newY);
        break;
      case CharacterType.Hero1:
        if (character.x == newX) {
          // Horizontal move
          int minY = character.y < newY ? character.y : newY;
          int maxY = character.y > newY ? character.y : newY;
          opponents.removeWhere((c) => c.x == newX && c.y >= minY && c.y <= maxY);
        } else if (character.y == newY) {
          // Vertical move
          int minX = character.x < newX ? character.x : newX;
          int maxX = character.x > newX ? character.x : newX;
          opponents.removeWhere((c) => c.y == newY && c.x >= minX && c.x <= maxX);
        }
        _updateLostCharacters(opponents, newX, newY);
        break;
      case CharacterType.Hero2:
      // Diagonal move
        List<List<int>> directions = [
          [-1, -1], // Top-left
          [1, -1],  // Top-right
          [-1, 1],  // Bottom-left
          [1, 1],   // Bottom-right
        ];

        for (var dir in directions) {
          int dx = dir[0];
          int dy = dir[1];
          for (int step = 1; step <= 2; step++) {
            int newX = character.x + step * dx;
            int newY = character.y + step * dy;
            if (isMoveValid(character, newX, newY)) {
              opponents.removeWhere((c) => c.x == newX && c.y == newY);
            } else {
              break; // Stop checking further in this direction if the move is invalid
            }
          }
        }
        _updateLostCharacters(opponents, newX, newY);
        break;
    }
  }

  // Update the list of lost characters
  void _updateLostCharacters(List<Character> opponents, int newX, int newY) {
    List<Character> lostCharacters = isPlayer1Turn ? player2LostCharacters : player1LostCharacters;
    lostCharacters.addAll(opponents.where((c) => c.x == newX && c.y == newY));
  }

  // Get possible moves for a character
  List<Position> getPossibleMoves(Character character) {
    List<Position> possibleMoves = [];

    switch (character.type) {
      case CharacterType.Pawn:
      // Pawn moves 1 step in any of the four cardinal directions
        for (int dx = -1; dx <= 1; dx++) {
          for (int dy = -1; dy <= 1; dy++) {
            if ((dx == 0) != (dy == 0)) { // Only horizontal or vertical moves
              int newX = character.x + dx;
              int newY = character.y + dy;
              if (isMoveValid(character, newX, newY)) {
                possibleMoves.add(Position(newX, newY));
              }
            }
          }
        }
        break;
      case CharacterType.Hero1:
      // Hero1 moves 1 or 2 steps in any of the four cardinal directions
        for (int i = 1; i <= 2; i++) {
          for (int dx = -1; dx <= 1; dx += 2) {
            int newX = character.x + i * dx;
            int newY = character.y;
            if (isMoveValid(character, newX, newY)) possibleMoves.add(Position(newX, newY));
          }
          for (int dy = -1; dy <= 1; dy += 2) {
            int newX = character.x;
            int newY = character.y + i * dy;
            if (isMoveValid(character, newX, newY)) possibleMoves.add(Position(newX, newY));
          }
        }
        break;
      case CharacterType.Hero2:
      // Hero2 moves 1 or 2 steps diagonally in all four diagonal directions
        List<List<int>> directions = [
          [-1, -1], // Top-left
          [1, -1],  // Top-right
          [-1, 1],  // Bottom-left
          [1, 1],   // Bottom-right
        ];

        for (var dir in directions) {
          int dx = dir[0];
          int dy = dir[1];
          for (int step = 1; step <= 2; step++) {
            int newX = character.x + step * dx;
            int newY = character.y + step * dy;
            if (isMoveValid(character, newX, newY)) {
              possibleMoves.add(Position(newX, newY));
            } else {
              break; // Stop checking further in this direction if the move is invalid
            }
          }
        }
        break;
    }

    return possibleMoves;
  }

  // Check for game over
  bool isGameOver() {
    return player1Characters.isEmpty || player2Characters.isEmpty;
  }
}
