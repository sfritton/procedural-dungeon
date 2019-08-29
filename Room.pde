class Room {
  float x1 = 0;
  float x2 = 0;
  float y1 = 0;
  float y2 = 0;
  Door[] exits = {};
  Door entrance;
  int level = 0;
  int maxLevel = 0;
  
  public Room(float x1, float x2, float y1, float y2) {
    this.x1 = x1;
    this.x2 = x2;
    this.y1 = y1;
    this.y2 = y2;
  }
  
  public void render(int maxLevel) {
    if (this.level == 0) {
      fill(COLOR_ENTRANCE);
    } else if (this.level == maxLevel) {
      fill(COLOR_EXIT);
    } else if (SHOW_PATH && this.maxLevel == maxLevel) {
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
    
    this.renderLevel();
    
    for (int i=0; i < this.exits.length; i++) {
      this.exits[i].render(maxLevel);
    }
  }
  
  public void renderLevel() {
    if (!SHOW_LEVELS) return;
    
    fill(COLOR_WALL);
    
    textSize(32);
    textAlign(CENTER, CENTER);
    textSize(32);
    text(this.level, this.x1 + (this.x2 - this.x1) / 2, this.y1 + (this.y2 - this.y1) / 2);
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
}