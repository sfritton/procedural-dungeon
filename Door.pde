class Door {
  boolean isVertical;
  PVector position;
  Room from, to;
  boolean onPath = false;
  boolean isLocked = false;
  
  public Door(Room from, Room to) {
    this.from = from;
    this.to = to;
    
    Direction direction = from.isNeighbor(to);
    float b = 0;
    
    // use the direction to set isVertical and the secondary axis
    switch(direction) {
      case NORTH:
        this.isVertical = false;
        b = from.y1;
        break;
      case EAST:
        isVertical = true;
        b = from.x2;
        break;
      case SOUTH:
        this.isVertical = false;
        b = from.y2;
        break;
      case WEST:
        this.isVertical = true;
        b = from.x1;
        break;
    }
    
    if (this.isVertical) {
      float a1 = max(from.y1, to.y1);
      float a2 = min(from.y2, to.y2);
      float a = random(a1 + DOOR_HALF_WIDTH + MARGIN, a2 - DOOR_HALF_WIDTH - MARGIN);
      this.position = new PVector(b, a);
    } else {
      float a1 = max(from.x1, to.x1);
      float a2 = min(from.x2, to.x2); 
      float a = random(a1 + DOOR_HALF_WIDTH + MARGIN, a2 - DOOR_HALF_WIDTH - MARGIN);
      this.position = new PVector(a, b);
    }
  }
  
  public void render() {
    if (this.isLocked) {
      fill(COLOR_DOOR_LOCKED);
    } else if (SHOW_PATH && this.onPath) {
      fill(COLOR_PATH);
    } else {
      fill(COLOR_ROOM);
    }
    
    if (this.isVertical) {
        beginShape();
        vertex(this.position.x - MARGIN * 2, this.position.y - DOOR_HALF_WIDTH);
        vertex(this.position.x + MARGIN * 2, this.position.y - DOOR_HALF_WIDTH);
        vertex(this.position.x + MARGIN * 2, this.position.y + DOOR_HALF_WIDTH);
        vertex(this.position.x - MARGIN * 2, this.position.y + DOOR_HALF_WIDTH);
        endShape();
    } else {
      beginShape();
      vertex(this.position.x - DOOR_HALF_WIDTH, this.position.y - MARGIN * 2);
      vertex(this.position.x + DOOR_HALF_WIDTH, this.position.y - MARGIN * 2);
      vertex(this.position.x + DOOR_HALF_WIDTH, this.position.y + MARGIN * 2);
      vertex(this.position.x - DOOR_HALF_WIDTH, this.position.y + MARGIN * 2);
      endShape();
    }
    
    this.to.render();
  }
}