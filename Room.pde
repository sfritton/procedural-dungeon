class Room {
  float x1 = 0;
  float x2 = 0;
  float y1 = 0;
  float y2 = 0;
  Door[] exits = {};
  Door entrance;
  int level = 0;
  int maxLevel = 0;
  boolean isDungeonEntrance = false;
  boolean isDungeonExit = false;
  boolean onPath = false;
  boolean hasKey = false;
  
  public Room(float x1, float x2, float y1, float y2) {
    this.x1 = x1;
    this.x2 = x2;
    this.y1 = y1;
    this.y2 = y2;
  }
  
  public void render() {
    if (this.level == 0) {
      fill(COLOR_ENTRANCE);
    } else if (this.isDungeonExit) {
      fill(COLOR_EXIT);
    } else if (SHOW_PATH && this.onPath) {
      fill(COLOR_PATH);
    } else {
      fill(COLOR_ROOM);
    }
    
    beginShape();
    vertex(this.x1 + MARGIN, this.y1 + MARGIN);
    vertex(this.x2 - MARGIN, this.y1 + MARGIN);
    vertex(this.x2 - MARGIN, this.y2 - MARGIN);
    vertex(this.x1 + MARGIN, this.y2 - MARGIN);
    endShape();
    
    this.renderText();
    
    for (int i=0; i < this.exits.length; i++) {
      this.exits[i].render();
    }
  }
  
  public void renderText() {
    if (!SHOW_LEVELS && !this.hasKey) return;
    
    fill(COLOR_WALL);
    
    textSize(32);
    textAlign(CENTER, CENTER);
    
    if (this.hasKey) {
      translate(this.x1 + (this.x2 - this.x1) / 2, this.y1 + (this.y2 - this.y1) / 2);
      rotate(PI/2);
      text("F", 1, -10);
      text("O", -1, 11);
      resetMatrix();
    } else {
      text(this.level, this.x1 + (this.x2 - this.x1) / 2, this.y1 + (this.y2 - this.y1) / 2);
    }
  }
  
  public Direction isNeighbor(Room other) {
    // north
    if (this.y1 == other.y2 && (other.x2 - this.x1 > MIN_WALL_LENGTH) && (this.x2 - other.x1 > MIN_WALL_LENGTH)) return Direction.NORTH;
    
    // east
    if (this.x2 == other.x1 && (other.y2 - this.y1 > MIN_WALL_LENGTH) && (this.y2 - other.y1 > MIN_WALL_LENGTH)) return Direction.EAST;
    
    // south
    if (this.y2 == other.y1 && (other.x2 - this.x1 > MIN_WALL_LENGTH) && (this.x2 - other.x1 > MIN_WALL_LENGTH)) return Direction.SOUTH;
    
    // west
    if (this.x1 == other.x2 && (other.y2 - this.y1 > MIN_WALL_LENGTH) && (this.y2 - other.y1 > MIN_WALL_LENGTH)) return Direction.WEST;
    
    return null;
  }
  
  public int findExits(Room[] candidates) {
    if (candidates.length == 0) return this.level;
    
    for (int i=0; i < candidates.length; i++) {
      Direction direction = this.isNeighbor(candidates[i]);
      
      // ignore non-neighbors and rooms that have already been claimed
      if (direction == null || candidates[i].entrance != null) {
        continue;
      };
      
      Door door = new Door(this, candidates[i]);
      
      this.exits = (Door[]) append(this.exits, door);
      candidates[i].entrance = door;
      candidates[i].level = this.level + 1;
    }
    
    this.maxLevel = this.level;
    
    for (int i=0; i < this.exits.length; i++) {
      int exitLevel = this.exits[i].to.findExits(candidates);
      if (exitLevel > this.maxLevel) this.maxLevel = exitLevel;
    }
    
    return this.maxLevel;
  }
  
  public Room findDungeonExit() {
    if (!this.isDungeonEntrance) return null;
    
    Room exit = this.findMaxLevelDescendent();
    exit.isDungeonExit = true;
    return exit;
  }
  
  public Room findMaxLevelDescendent() {
    if (this.exits.length == 0) {
      return this;
    }
    
    Room maxChild = this.exits[0].to;
    
    for (int i=1; i < this.exits.length; i++) {
      Room candidate = this.exits[i].to;
      if (candidate.maxLevel > maxChild.maxLevel)
      
      maxChild = candidate;
    }
    
    return maxChild.findMaxLevelDescendent();
  }
  
  public void findPath() {
    if (!this.isDungeonExit) return;
    
    Door entrance = this.entrance;
    
    while (entrance != null) {
      entrance.onPath = true;
      entrance.from.onPath = true;
      
      entrance = entrance.from.entrance;
    }
  }
  
  private Door findNonPathExit() {
    Door maxLevelNonPathExit = null;
    
    for (int i=0; i < this.exits.length; i++) {
      if (this.exits[i].onPath) continue;
      
      if (maxLevelNonPathExit == null || this.exits[i].to.maxLevel > maxLevelNonPathExit.to.maxLevel) {
        maxLevelNonPathExit = this.exits[i];
      }; 
    }
    
    return maxLevelNonPathExit;
  }
  
  private Door findPathExit() {
    for (int i=0; i < this.exits.length; i++) {
      if (this.exits[i].onPath) return this.exits[i]; 
    }
    
    return null;
  }
  
  // returns true if a key was successfully placed, false otherwise
  public boolean placeKey() {
    if (!this.isDungeonExit) return false;
    
    int distance = int(random(1, this.level - 1));
    
    Room room = this;
    
    // walk up the tree for distance levels
    for (int i=distance; i > 0; i--) {
      room = room.entrance.from;
    }
    
    Door nonPathExit = null;
    
    while (nonPathExit == null) {
      nonPathExit = room.findNonPathExit();
    
      if (nonPathExit == null) {
        if (room.entrance == null) return false;
        
        // walk up another level
        room = room.entrance.from;
      }
    }
    
    // place the lock
    room.findPathExit().isLocked = true;
    
    Room keyRoom = nonPathExit.to.findMaxLevelDescendent();
    
    // place the key
    keyRoom.hasKey = true;
    
    return true;
  }
}