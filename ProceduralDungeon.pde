Room[] rooms;
Room dungeonEntrance;
Room dungeonExit;
int maxLevel = 0;

void setup() {
  size(1600, 1600);
  noStroke();
  
  generateDungeon();
  renderDungeon();
}

void draw() {
}

void keyPressed() {
  switch(key) {
    case ' ':
      generateDungeon();
      break;
    case 'p':
      SHOW_PATH = !SHOW_PATH;
      break;
    case 'l':
      SHOW_LEVELS = !SHOW_LEVELS;
      break;
    default:
      return;
  }
  
  renderDungeon();
}

void generateDungeon() {
  // divide the screen into rooms
  rooms = divide(DEPTH);
  
  dungeonEntrance = rooms[0];
  dungeonEntrance.isDungeonEntrance = true;
  
  // connect those rooms with doors, storing the longest path
  maxLevel = dungeonEntrance.findExits((Room[]) subset(rooms, 1));
  
  // choose an exit
  dungeonExit = dungeonEntrance.findDungeonExit();
  
  // find the path from the entrance to the exit
  dungeonExit.findPath();
  
  
  int numKeys = int(random(1, 4));
  
  // place locks on doors along the path
  for (int i=0; i < numKeys; i++) {
    dungeonExit.placeKey();
  } 
}

void renderDungeon() {
  background(0);
  dungeonEntrance.render();
}

Room[] divide(int depth) {
  Room[] empty = {};
  return divide(new Room(MARGIN, width - MARGIN, MARGIN, height - MARGIN), depth, empty);
}

Room[] divide(Room room, int depth, Room[] results) {
  if (depth == 0) {
    return (Room[]) append(results, room);
  }
  
  boolean isVertical = depth % 2 == 0;
  boolean flip = random(1) > .85; // 15% of the time, break from the normal pattern
  
  if (flip ? !isVertical : isVertical) {
    float middleX = randomMiddle(room.x1, room.x2);
    
    if (room.x2 - middleX < MIN_WALL_LENGTH || middleX - room.x1 < MIN_WALL_LENGTH) {
      return divide(room, depth - 1, results);
    }
    
    return (Room[]) concat(
      divide(new Room(room.x1, middleX, room.y1, room.y2), depth - 1, results), 
      divide(new Room(middleX, room.x2, room.y1, room.y2), depth - 1, results)
    );
  }
  
  float middleY = randomMiddle(room.y1, room.y2);
  
  if (room.y2 - middleY < MIN_WALL_LENGTH || middleY - room.y1 < MIN_WALL_LENGTH) {
    return divide(room, depth - 1, results);
  }
  
  return (Room[]) concat(
    divide(new Room(room.x1, room.x2, room.y1, middleY), depth - 1, results), 
    divide(new Room(room.x1, room.x2, middleY, room.y2), depth - 1, results)
  );
}

float randomMiddle(float min, float max) {
  return min + ((max - min) * (0.5 + random(-MULTIPLIER, MULTIPLIER)));
}