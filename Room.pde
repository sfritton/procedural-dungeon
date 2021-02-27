class Room {
  int x1 = 0;
  int x2 = 0;
  int y1 = 0;
  int y2 = 0;
  Door[] exits = {};
  Door entrance;
  int depth = 0;
  int maxDepth = 0;
  boolean isDungeonEntrance = false;
  boolean isDungeonExit = false;
  boolean onPath = false;
  boolean hasKey = false;
  boolean isVisible = false;
  RoomType type, nextType, prevType;
  
  public Room(int x1, int x2, int y1, int y2) {
    this.x1 = x1;
    this.x2 = x2;
    this.y1 = y1;
    this.y2 = y2;
  }
  
  public void render() {
    if (this.isDungeonEntrance) {
      this.isVisible = true;
    } else if (mouseX > this.x1 && mouseX < this.x2 && mouseY > this.y1 && mouseY < this.y2) {
      this.isVisible = this.entrance.from.isVisible;
    }
    
    if (!SHOW_ALL_ROOMS && !this.isVisible) return;
    
    if (this.depth == 0) {
      fill(COLOR_ENTRANCE);
    } else if (this.isDungeonExit) {
      fill(COLOR_EXIT);
    } else if (SHOW_PATH && this.onPath) {
      fill(COLOR_PATH);
    } else if (SHOW_ROOM_TYPES && this.prevType != this.type) {
      fill(COLOR_CHANGE);
    } else {
      fill(COLOR_ROOM);
    }
    
    beginShape();
    vertex(this.x1, this.y1);
    vertex(this.x2, this.y1);
    vertex(this.x2, this.y2);
    vertex(this.x1, this.y2);
    endShape();
    
    this.renderText();
    
    for (int i=0; i < this.exits.length; i++) {
      this.exits[i].render();
    }
  }
  
  public void renderKey() {
    translate(this.x1 + (this.x2 - this.x1) / 2, this.y1 + (this.y2 - this.y1) / 2);
    rotate(3 * PI/4);
    text("F", 1, -FONT_SIZE * .375 + 1);
    text("O", -1, FONT_SIZE * .375);
    resetMatrix();
  }
  
  public void renderText() {
    fill(COLOR_WALL);
    
    textSize(FONT_SIZE);
    textAlign(CENTER, CENTER);
    
    if (this.hasKey) {
      this.renderKey();
    } else if (SHOW_ROOM_TYPES && this.type != null) {
      text(this.type.value, this.x1 + (this.x2 - this.x1) / 2, this.y1 + (this.y2 - this.y1) / 2);
    } else if (SHOW_DEPTH) {
      text(this.depth, this.x1 + (this.x2 - this.x1) / 2, this.y1 + (this.y2 - this.y1) / 2);
    }
  }
  
  public Direction isNeighbor(Room other) {
    // north
    if (this.y1 == other.y2 + UNIT && (other.x2 - this.x1 > MIN_WALL_LENGTH) && (this.x2 - other.x1 > MIN_WALL_LENGTH)) return Direction.NORTH;
    
    // east
    if (this.x2 == other.x1 - UNIT && (other.y2 - this.y1 > MIN_WALL_LENGTH) && (this.y2 - other.y1 > MIN_WALL_LENGTH)) return Direction.EAST;
    
    // south
    if (this.y2 == other.y1 - UNIT && (other.x2 - this.x1 > MIN_WALL_LENGTH) && (this.x2 - other.x1 > MIN_WALL_LENGTH)) return Direction.SOUTH;
    
    // west
    if (this.x1 == other.x2 + UNIT && (other.y2 - this.y1 > MIN_WALL_LENGTH) && (this.y2 - other.y1 > MIN_WALL_LENGTH)) return Direction.WEST;
    
    return null;
  }
  
  public int findExits(Room[] candidates) {
    if (candidates.length == 0) return this.depth;
    
    for (int i=0; i < candidates.length; i++) {
      Direction direction = this.isNeighbor(candidates[i]);
      
      if (
        direction == null || // ignore non-neighbors
        candidates[i].entrance != null || candidates[i].isDungeonEntrance == true || // ignore rooms that have already been claimed
        random(1) > .85 // ignore 15% of valid connections
      ) {
        continue;
      };
      
      Door door = new Door(this, candidates[i]);
      
      this.exits = (Door[]) append(this.exits, door);
      candidates[i].entrance = door;
      candidates[i].depth = this.depth + 1;
    }
    
    this.maxDepth = this.depth;
    
    for (int i=0; i < this.exits.length; i++) {
      int exitDepth = this.exits[i].to.findExits(candidates);
      if (exitDepth > this.maxDepth) this.maxDepth = exitDepth;
    }
    
    return this.maxDepth;
  }
  
  public Room findDungeonExit() {
    if (!this.isDungeonEntrance) return null;
    
    Room exit = this.findMaxDepthDescendent();
    exit.isDungeonExit = true;
    return exit;
  }
  
  public Room findMaxDepthDescendent() {
    if (this.exits.length == 0) {
      return this;
    }
    
    Room maxChild = this.exits[0].to;
    
    for (int i=1; i < this.exits.length; i++) {
      Room candidate = this.exits[i].to;
      if (candidate.maxDepth > maxChild.maxDepth)
      
      maxChild = candidate;
    }
    
    return maxChild.findMaxDepthDescendent();
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
    Door maxDepthNonPathExit = null;
    
    for (int i=0; i < this.exits.length; i++) {
      if (this.exits[i].onPath) continue;
      
      if (maxDepthNonPathExit == null || this.exits[i].to.maxDepth > maxDepthNonPathExit.to.maxDepth) {
        maxDepthNonPathExit = this.exits[i];
      }; 
    }
    
    return maxDepthNonPathExit;
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
    
    int distance = int(random(1, this.depth - 1));
    
    Room room = this;
    
    // walk up the tree for distance levels
    for (int i=distance; i > 0 && room.entrance != null; i--) {
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
    
    Room keyRoom = nonPathExit.to.findMaxDepthDescendent();
    
    // place the key
    keyRoom.hasKey = true;
    
    return true;
  }
  
  public RoomType getChildType() {
    if (this.exits.length < 1) return null;
    
    Room maxPriorityChild = this.exits[0].to;
    
    for (int i=1; i < this.exits.length; i++) {
      if (this.exits[i].to.type.priority > maxPriorityChild.type.priority)
        maxPriorityChild = this.exits[i].to;
    }
    
    return maxPriorityChild.type;
  }
  
  public void updateRoomTypes() {
    this.prevType = this.type;
    this.type = this.nextType;
    
    for (int i=0; i < this.exits.length; i++) {
      this.exits[i].to.updateRoomTypes();
    }
  }
  
  public RoomType getParentType() {
    if (this.entrance == null) return null;
    
    return this.entrance.from.type;
  }
  
  public void chooseNextTypes() {
    this.nextType = this.chooseNextType();
    
    for (int i=0; i < this.exits.length; i++) {
      this.exits[i].to.chooseNextTypes();
    }
  }
  
  public RoomType chooseNextType() {
    if (this.isDungeonEntrance || this.isDungeonExit) {
      return RoomType.EMPTY;
    } else if (this.hasKey) {
      return RoomType.REWARD;
    }
    
    RoomType parent = this.getParentType();
    int numChildren = this.exits.length;
    
    if (parent == null) return RoomType.EMPTY;
    
    switch (parent) {
      case MINI_BOSS:
      case TRAP:
        switch (numChildren) {
          case 0:
            return RoomType.REWARD;
          case 1:
            return RoomType.SWARM;
          default:
            return RoomType.EMPTY;
        }
      case EMPTY:
      case SWARM:
        switch (numChildren) {
          case 0:
            return RoomType.SWARM;
          case 1:
            return RoomType.TRAP;
          default:
            return RoomType.MINI_BOSS;
        }
      case REWARD:
        switch (numChildren) {
          case 0:
            return randomRoomType(RoomType.EMPTY);
          case 1:
            return random(1) > 0.5 ? RoomType.MINI_BOSS : RoomType.TRAP;
          default:
            return RoomType.SWARM;
        }
      default:
        return RoomType.EMPTY;
    }
  }
}