import 'dart:io';
import 'dart:math';

// Константы для размера поля и символов
const int BOARD_SIZE = 10;
const String EMPTY = '~';
const String SHIP = '#';
const String HIT = 'X';
const String MISS = 'O';

// Класс для представления игрового поля
class Board {
  List<List<String>> grid = List.generate(
      BOARD_SIZE, (_) => List.filled(BOARD_SIZE, EMPTY));

  // Отображение поля в консоли
  void display({bool hideShips = true}) {
    // Заголовки столбцов
    stdout.write("   ");
    for (int i = 0; i < BOARD_SIZE; i++) {
      stdout.write("${String.fromCharCode(65 + i)} "); // A, B, C...
    }
    stdout.writeln();

    for (int i = 0; i < BOARD_SIZE; i++) {
      // Заголовки строк (номера)
      stdout.write("${i + 1} ".padLeft(3));

      for (int j = 0; j < BOARD_SIZE; j++) {
        if (hideShips && grid[i][j] == SHIP) {
          stdout.write("$EMPTY ");
        } else {
          stdout.write("${grid[i][j]} ");
        }
      }
      stdout.writeln();
    }
  }

  // Размещение корабля на поле
  bool placeShip(int row, int col, int length, bool isHorizontal) {
    if (!isValidPlacement(row, col, length, isHorizontal)) {
      return false;
    }

    for (int i = 0; i < length; i++) {
      if (isHorizontal) {
        grid[row][col + i] = SHIP;
      } else {
        grid[row + i][col] = SHIP;
      }
    }
    return true;
  }

  // Проверка, допустимо ли размещение корабля в указанной позиции
  bool isValidPlacement(int row, int col, int length, bool isHorizontal) {
    if (row < 0 || row >= BOARD_SIZE || col < 0 || col >= BOARD_SIZE) {
      return false;
    }

    if (isHorizontal && col + length > BOARD_SIZE) {
      return false;
    }

    if (!isHorizontal && row + length > BOARD_SIZE) {
      return false;
    }

    // Проверка на соседние клетки (чтобы корабли не касались друг друга)
    for (int i = -1; i <= length; i++) {
      for (int j = -1; j <= 1; j++) {
        int checkRow = row + (isHorizontal ? j : i);
        int checkCol = col + (isHorizontal ? i : j);

        if (checkRow >= 0 && checkRow < BOARD_SIZE &&
            checkCol >= 0 && checkCol < BOARD_SIZE) {
          if (grid[checkRow][checkCol] == SHIP) {
            return false;
          }
        }
      }
    }

    return true;
  }

  // Атака на указанную клетку
  bool attack(int row, int col) {
    if (grid[row][col] == SHIP) {
      grid[row][col] = HIT;
      return true;
    } else if (grid[row][col] == EMPTY) {
      grid[row][col] = MISS;
                  return false;
    } else {
      // Уже атаковали эту клетку
      return false; // или можно бросить исключение
    }
  }

  // Проверка, остались ли корабли на поле
  bool allShipsSunk() {
    for (int i = 0; i < BOARD_SIZE; i++) {
      for (int j = 0; j < BOARD_SIZE; j++) {
        if (grid[i][j] == SHIP) {
          return false;
        }
      }
    }
    return true;
  }

  // Подсчет оставшихся кораблей
  int countRemainingShips() {
    int count = 0;
    for (int i = 0; i < BOARD_SIZE; i++) {
      for (int j = 0; j < BOARD_SIZE; j++) {
        if (grid[i][j] == SHIP) {
          count++;
        }
      }
    }
    return count;
  }
}

// Функция для получения координат от игрока
List<int> getCoordinatesFromPlayer() {
  while (true) {
    stdout.write("Введите координаты атаки (например, A1): ");
    String? input = stdin.readLineSync();

    if (input == null || input.isEmpty) {
      print("Некорректный ввод. Пожалуйста, попробуйте снова.");
      continue;
    }

    input = input.toUpperCase();
    if (input.length < 2) {
      print("Некорректный ввод. Пожалуйста, попробуйте снова.");
      continue;
    }

    int col = input.codeUnitAt(0) - 65; // Преобразуем букву в индекс (A -> 0, B -> 1, ...)
    int? row = int.tryParse(input.substring(1))?.toInt(); // Номер строки

    if (col < 0 || col >= BOARD_SIZE || row == null || row < 1 || row > BOARD_SIZE) {
      print("Некорректные координаты. Пожалуйста, попробуйте снова.");
      continue;
    }

    return [row - 1, col]; // Возвращаем индексы, начиная с 0
  }
}

// Функция для автоматического размещения кораблей на поле компьютера
void placeComputerShips(Board board) {
  final random = Random();
  List<int> shipLengths = [5, 4, 3, 3, 2]; // Размеры кораблей

  for (int length in shipLengths) {
    bool placed = false;
    while (!placed) {
      int row = random.nextInt(BOARD_SIZE);
      int col = random.nextInt(BOARD_SIZE);
      bool isHorizontal = random.nextBool();

      if (board.placeShip(row, col, length, isHorizontal)) {
        placed = true;
      }
    }
  }
}

// Функция для получения координат и ориентации от игрока для размещения корабля
List<dynamic> getShipPlacementFromPlayer(int shipLength) {
  while (true) {
        stdout.write("Введите координаты начала для корабля длиной $shipLength (например, A1): ");
    String? inputCoordinates = stdin.readLineSync();
    stdout.write("Горизонтально? (y/n): ");
    String? inputOrientation = stdin.readLineSync();

    if (inputCoordinates == null || inputOrientation == null) {
      print("Ошибка ввода. Повторите.");
      continue;
    }

    inputCoordinates = inputCoordinates.toUpperCase();
    if (inputCoordinates.length < 2) {
      print("Некорректный ввод координат. Пожалуйста, попробуйте снова.");
      continue;
    }

    int col;
    try {
      col = inputCoordinates.codeUnitAt(0) - 65; // Преобразуем букву в индекс (A -> 0, B -> 1, ...)
      if (col < 0 || col >= BOARD_SIZE){
        print("Некорректный ввод координат. Пожалуйста, попробуйте снова.");
        continue;
      }
    } catch (e) {
      print("Некорректный ввод координат. Пожалуйста, попробуйте снова.");
      continue;
    }

    int? row = int.tryParse(inputCoordinates.substring(1))?.toInt(); // Номер строки
    if (row == null || row < 1 || row > BOARD_SIZE) {
      print("Некорректный ввод координат. Пожалуйста, попробуйте снова.");
      continue;
    }

    bool horizontal = inputOrientation.toLowerCase() == "y";

    return [row - 1, col, horizontal];
  }
}


void main() {
  final playerBoard = Board();
  final computerBoard = Board();
  final random = Random();

  // Автоматическое размещение кораблей компьютера
  placeComputerShips(computerBoard);

  // Размещение кораблей игрока (интерактивное)
  print("Начнем размещение ваших кораблей. (Пример: введите координаты и ориентацию)");
  playerBoard.display(hideShips: false);

  List<int> shipLengths = [5, 4, 3, 3, 2];
  for (int length in shipLengths) {
    bool shipPlaced = false;
    while (!shipPlaced) {
      List<dynamic> placement = getShipPlacementFromPlayer(length);
      int row = placement[0];
      int col = placement[1];
      bool horizontal = placement[2];

      if (playerBoard.placeShip(row, col, length, horizontal)) {
        shipPlaced = true;
        playerBoard.display(hideShips: false);
      } else {
        print("Невозможно разместить корабль в этих координатах. Повторите.");
      }
    }
  }

  print("Ваши корабли размещены.");

  // Основной игровой цикл
  bool gameOver = false;
  bool playerTurn = true; // Начинает игрок

  while (!gameOver)
  {
    if (playerTurn) {
      // Ход игрока
      print("\nВаш ход:");
      playerBoard.display(hideShips: false); // Показываем поле игрока
      computerBoard.display(); // Показываем поле компьютера (скрытые корабли)

      List<int> coordinates = getCoordinatesFromPlayer();
      int row = coordinates[0];
      int col = coordinates[1];

      bool hit = computerBoard.attack(row, col);

      if (hit) {
        print("Попадание!");
        // Ход остается у игрока
      } else {
        print("Мимо.");
        playerTurn = false; // Переход хода к компьютеру
      }

      if (computerBoard.allShipsSunk()) {
        print("Вы победили!");
        gameOver = true;
        break;
      }
    } else {
      // Ход компьютера (простой случайный выбор)
      print("\nХод компьютера:");
      bool computerHit = false;
      int computerRow, computerCol;
      do {
        computerRow = random.nextInt(BOARD_SIZE);
        computerCol = random.nextInt(BOARD_SIZE);

        computerHit = playerBoard.attack(computerRow, computerCol);
        if (computerHit){
          print("Компьютер попал в ${String.fromCharCode(65 + computerCol)}${computerRow + 1}!");
        } else {
          break; // Если промах, выходим из цикла do-while
        }
      } while (computerHit); // Компьютер ходит, пока попадает

      if (playerBoard.allShipsSunk()) {
        print("Компьютер победил!");
        gameOver = true;
        break;
      }
      playerTurn = true; // Переход хода к игроку после хода компьютера (независимо от попадания)
    }
  }

  print("\nИгра окончена.");
  playerBoard.display(hideShips: false);
  computerBoard.display(hideShips: false); // Показываем финальное поле компьютера

  // Вывод статистики
  int playerShipsRemaining = playerBoard.countRemainingShips();
  int computerShipsRemaining = computerBoard.countRemainingShips();

  print("Статистика:");
  if (playerBoard.allShipsSunk()){
    print("У компьютера осталось кораблей: $computerShipsRemaining");
  } else {
    print("У вас осталось кораблей: $playerShipsRemaining");
  }

}





// A1
// y
// A3
// y
// A5
// y
// A7
// y
// A9
// y
