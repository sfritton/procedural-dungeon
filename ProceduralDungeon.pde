Room[] rooms;
Room dungeonEntrance;
Room dungeonExit;
int maxDepth = 0;

void setup() {
  size(1600, 1600);
  noStroke();
  
  generateDungeon();
  renderDungeon();
}

void draw() {
  renderDungeon();
}

void keyPressed() {
  switch(key) {
    case ' ':
      generateDungeon();
      break;
    case 'p':
      SHOW_PATH = !SHOW_PATH;
      break;
    case 'd':
      SHOW_DEPTH = !SHOW_DEPTH;
      break;
    case 'v':
      SHOW_ALL_ROOMS = !SHOW_ALL_ROOMS;
      break;
    case 't':
      SHOW_ROOM_TYPES = !SHOW_ROOM_TYPES;
      break;
    case 'g':
      // recursively choose next type for each room
      dungeonEntrance.chooseNextTypes();
      
      // assign next type to each room
      dungeonEntrance.updateRoomTypes();
      break;
    default:
      return;
  }
  
  renderDungeon();
}

void generateDungeon() {
  // divide the screen into rooms
  rooms = divide(DEPTH);
  
  dungeonEntrance = rooms[int(random(0, rooms.length -1))];
  dungeonEntrance.isDungeonEntrance = true;
  
  // connect those rooms with doors, storing the longest path
  maxDepth = dungeonEntrance.findExits(rooms);
  
  // choose an exit
  dungeonExit = dungeonEntrance.findDungeonExit();
  
  // find the path from the entrance to the exit
  dungeonExit.findPath();
  
  
  int numKeys = int(random(1, 4));
  
  // place locks on doors along the path
  for (int i=0; i < numKeys; i++) {
    dungeonExit.placeKey();
  }
  
  int generations = 25;
  
  //for (int i=0; i < generations; i++) {
  //  // recursively choose next type for each room
  //  dungeonEntrance.chooseNextTypes();
    
  //  // assign next type to each room
  //  dungeonEntrance.updateRoomTypes();
  //}
}

void renderDungeon() {
  background(0);
  dungeonEntrance.render();
}

Room[] divide(int depth) {
  Room[] empty = {};
  return divide(new Room(UNIT, width - UNIT, UNIT, height - UNIT), depth, empty);
}

Room[] divide(Room room, int depth, Room[] results) {
  if (depth == 0) {
    return (Room[]) append(results, room);
  }
  
  boolean isVertical = depth % 2 == 0;
  boolean flip = random(1) > .85; // 15% of the time, break from the normal pattern
  
  if (flip ? !isVertical : isVertical) {
    int middleX = randomMiddle(room.x1, room.x2);
    
    if (room.x2 - (middleX + UNIT) < MIN_WALL_LENGTH || middleX - room.x1 < MIN_WALL_LENGTH) {
      return divide(room, depth - 1, results);
    }
    
    return (Room[]) concat(
      divide(new Room(room.x1, middleX, room.y1, room.y2), depth - 1, results), 
      divide(new Room(middleX + UNIT, room.x2, room.y1, room.y2), depth - 1, results)
    );
  }
  
  int middleY = randomMiddle(room.y1, room.y2);
  
  if (room.y2 - (middleY + UNIT) < MIN_WALL_LENGTH || middleY - room.y1 < MIN_WALL_LENGTH) {
    return divide(room, depth - 1, results);
  }
  
  return (Room[]) concat(
    divide(new Room(room.x1, room.x2, room.y1, middleY), depth - 1, results), 
    divide(new Room(room.x1, room.x2, middleY + UNIT, room.y2), depth - 1, results)
  );
}

int randomMiddle(int min, int max) {
  return int((min + ((max - min) * (0.5 + random(-MULTIPLIER, MULTIPLIER))))/UNIT) * UNIT;
}