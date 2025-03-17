import 'dart:io';
import 'dart:math';
import 'constant.dart' as constant;

class Dungeon {
  final int width;
  final int height;
  late List<List<int>> map;
  final Random rand = Random();
  List<Point<int>> roomCenters = [];
  Point<int> playerPos = Point(0, 0);
  int viewDistance = 4;

  Dungeon(this.width, this.height) {
    _initializeMap();
    _generateRooms();
    _connectRooms();
    _placePlayer();
  }

  void _initializeMap() {
    map = List.generate(width, (_) => List.filled(height, 0));
  }

  void _generateRooms() {
    int roomCount = rand.nextInt(5) + 10;
    for (int i = 0; i < roomCount; i++) {
      int roomWidth = rand.nextInt(4) + 12;
      int roomHeight = rand.nextInt(4) + 8;
      int x = rand.nextInt(width - roomWidth - 2) + 1;
      int y = rand.nextInt(height - roomHeight - 2) + 1;

      for (int dx = 0; dx < roomWidth; dx++) {
        for (int dy = 0; dy < roomHeight; dy++) {
          map[x + dx][y + dy] = 1;
        }
      }
      roomCenters.add(Point(x + roomWidth ~/ 2, y + roomHeight ~/ 2));
    }
  }

  void _connectRooms() {
    roomCenters.sort((a, b) => a.x.compareTo(b.x));

    for (int i = 0; i < roomCenters.length - 1; i++) {
      Point<int> start = roomCenters[i];
      Point<int> end = roomCenters[i + 1];

      int x = start.x;
      int y = start.y;

      while (x != end.x) {
        map[x][y] = 2;
        x += (end.x > x) ? 1 : -1;
      }
      while (y != end.y) {
        map[x][y] = 2;
        y += (end.y > y) ? 1 : -1;
      }
    }
  }

  void _placePlayer() {
    playerPos = roomCenters.first;
  }

  bool isVisible(int x, int y) {
    int dx = x - playerPos.x;
    int dy = y - playerPos.y;
    if (dx * dx + dy * dy > viewDistance * viewDistance) return false;

    // Raycasting: 벽이 가로막지 않는지 확인
    int steps = max(dx.abs(), dy.abs());
    for (int i = 1; i <= steps; i++) {
      int px = playerPos.x + (dx * i ~/ steps);
      int py = playerPos.y + (dy * i ~/ steps);
      if (map[px][py] == 0) return false; // 벽이 있으면 가려짐
    }

    return true;
  }

  void printMap() {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (playerPos == Point(x, y)) {
          stdout.write(constant.player); // 캐릭터
          // } else if (isVisible(x, y)) {
        } else if (true) {
          if (map[x][y] == 0)
            stdout.write(constant.wall); // 벽
          else if (map[x][y] == 1)
            stdout.write('.'); // 방
          else
            stdout.write('.'); // 길
        } else {
          stdout.write(' '); // 보이지 않는 부분
        }
      }
      stdout.writeln();
    }
  }

  void movePlayer(int dx, int dy) {
    int newX = playerPos.x + dx;
    int newY = playerPos.y + dy;

    if (newX >= 0 &&
        newX < width &&
        newY >= 0 &&
        newY < height &&
        map[newX][newY] != 0) {
      playerPos = Point(newX, newY);
    }
  }

  void gameLoop() {
    // stdin.echoMode = false;
    // stdin.lineMode = false;
    print("이동: WASD (또는 화살표 키) | 종료: Q");

    while (true) {
      print("\x1B[2J\x1B[0;0H"); // 터미널 화면 초기화
      printMap();

      int key = stdin.readByteSync(); // 키 입력 받기

      switch (key) {
        case 119: // W
        case 27: // 방향키 입력의 첫 번째 바이트
          int next = stdin.readByteSync();
          if (next == 91) {
            int arrow = stdin.readByteSync();
            if (arrow == 65) movePlayer(0, -1); // 위쪽 방향키
            if (arrow == 66) movePlayer(0, 1); // 아래쪽 방향키
            if (arrow == 68) movePlayer(-1, 0); // 왼쪽 방향키
            if (arrow == 67) movePlayer(1, 0); // 오른쪽 방향키
          }
          break;
        case 115: // S
          movePlayer(0, 1);
          break;
        case 97: // A
          movePlayer(-1, 0);
          break;
        case 100: // D
          movePlayer(1, 0);
          break;
        case 113: // Q (게임 종료)
          print("게임을 종료합니다.");
          // stdin.echoMode = true;
          // stdin.lineMode = true;
          return;
      }
    }
  }
}

void main() {
  Dungeon game = Dungeon(80, 40);
  game.gameLoop();
}
