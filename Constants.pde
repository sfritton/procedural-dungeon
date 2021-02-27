static int SURFACE_MULTIPLIER = 2; // 1 for monitor, 2 for surface
static int UNIT = SURFACE_MULTIPLIER * 10;
static int DEPTH = 5;
static float MULTIPLIER = .25;
static int MIN_WALL_LENGTH = UNIT * 5;
static int DOOR_HALF_WIDTH = UNIT;
static int FONT_SIZE = SURFACE_MULTIPLIER * 16;

// flags
static boolean SHOW_PATH = false;
static boolean SHOW_DEPTH = false;
static boolean SHOW_ALL_ROOMS = true;
static boolean SHOW_ROOM_TYPES = true;

color COLOR_DOOR = color(220);
color COLOR_ROOM = color(255);
color COLOR_WALL = color(0);
color COLOR_ENTRANCE = color(255, 200, 200);
color COLOR_EXIT = color(200, 200, 255);
color COLOR_PATH = color(225, 210, 255);
color COLOR_CHANGE = color(225, 255, 210);
color COLOR_DOOR_LOCKED = color(255, 50, 50);