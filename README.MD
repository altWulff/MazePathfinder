 # Maze pathfinder
The program determines the shortest path in the maze from a file, in the format:
`0` - impassable area (wall),
` `(space) - passable area,
`I` - entrance to the maze, `E` - exit from the maze.
It follows the path from the starting point `I` to `E` and outputs the finished path to the test file,
marking the path with `@`.

## Setup
`$ git clone git@github.com:altWulff/MazePathfinder.git && cd MazePathfinder`

`$ virtualenv venv && source venv/bin/activate`

## Usage
`$ python src/main.py --input INPUT_FILE --output OUTPUT_FILE`

### Example usage
`$ python src/main.py --input "./Maze.txt" --output "./Maze_w_path.txt"`
