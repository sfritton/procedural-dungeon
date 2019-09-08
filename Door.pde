class Door {
  Room from, to;
  boolean onPath = false;
  boolean isLocked = false;
  int x1, x2, y1, y2;
  
  public Door(Room from, Room to) {
    this.from = from;
    this.to = to;
    
    Direction direction = from.isNeighbor(to);
    boolean isVertical = false;
    
    // use the direction to set isVertical and the secondary axis
    switch(direction) {
      case NORTH:
        isVertical = false;
        this.y1 = from.y1 - UNIT;
        this.y2 = from.y1;
        break;
      case EAST:
        isVertical = true;
        this.x1 = from.x2;
        this.x2 = from.x2 + UNIT;
        break;
      case SOUTH:
        isVertical = false;
        this.y1 = from.y2;
        this.y2 = from.y2 + UNIT;
        break;
      case WEST:
        isVertical = true;
        this.x1 = from.x1 - UNIT;
        this.x2 = from.x1;
        break;
    }
    
    if (isVertical) {
      int a1 = max(from.y1, to.y1);
      int a2 = min(from.y2, to.y2);
      int a = int(random(a1 + DOOR_HALF_WIDTH + UNIT, a2 - DOOR_HALF_WIDTH - UNIT)/UNIT)*UNIT;
      this.y1 = a - DOOR_HALF_WIDTH;
      this.y2 = a + DOOR_HALF_WIDTH;
    } else {
      int a1 = max(from.x1, to.x1);
      int a2 = min(from.x2, to.x2); 
      int a = int(random(a1 + DOOR_HALF_WIDTH + UNIT, a2 - DOOR_HALF_WIDTH - UNIT)/UNIT)*UNIT;
      this.x1 = a - DOOR_HALF_WIDTH;
      this.x2 = a + DOOR_HALF_WIDTH;
    }
  }
  
  public void render() {
    if (this.isLocked) {
      fill(COLOR_DOOR_LOCKED);
    } else if (SHOW_PATH && this.onPath) {
      fill(COLOR_PATH);
    } else {
      fill(COLOR_DOOR);
    }
    
    beginShape();
    vertex(this.x1, this.y1);
    vertex(this.x2, this.y1);
    vertex(this.x2, this.y2);
    vertex(this.x1, this.y2);
    endShape();
    
    this.to.render();
  }
}