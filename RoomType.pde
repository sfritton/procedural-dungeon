enum RoomType {
  MINI_BOSS("M", 4, 400, 1),
  REWARD("R", 5),
  SWARM("S", 1, 200, 0),
  TRAP("T", 2, 400, 1),
  EMPTY("E", 0);
  
  public String value;
  public int minWallLength;
  public int minNumChildren;
  public int priority;
  
  private RoomType(String value, int priority) {
    this(value, priority, 0, 0);
  }
  
  private RoomType(String value, int priority, int minWallLength, int minNumChildren) {
    this.value = value;
    this.priority = priority;
    this.minWallLength = minWallLength;
    this.minNumChildren = minNumChildren;
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