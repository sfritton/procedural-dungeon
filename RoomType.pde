enum RoomType {
  MINI_BOSS("M", 4, UNIT * 20),
  REWARD("R", 5),
  SWARM("S", 1, UNIT * 10),
  TRAP("T", 2, UNIT * 15),
  EMPTY("E", 0);
  
  public String value;
  public int minWallLength;
  public int priority;
  
  private RoomType(String value, int priority) {
    this(value, priority, 0);
  }
  
  private RoomType(String value, int priority, int minWallLength) {
    this.value = value;
    this.priority = priority;
    this.minWallLength = minWallLength;
  }
}

public RoomType randomRoomType() {
  return randomRoomType(null);
}

// random will never return the REWARD type
public RoomType randomRoomType(RoomType exclude) {
  int index = int(random(4));
  
  RoomType type;
  
  switch (index) {
    case 0:
      type = RoomType.MINI_BOSS;
      break;
    case 1:
      type = RoomType.SWARM;
      break;
    case 2:
      type = RoomType.TRAP;
      break;
    default:
      type = RoomType.EMPTY;
      break;
  }
  
  if (type == exclude) return randomRoomType(exclude);
  
  return type;
}