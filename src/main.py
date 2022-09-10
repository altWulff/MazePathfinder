"""
Pathfinder in maze
catch txt file and return file
with maze path
"""

import argparse


def open_maze(file_path):
    """
    Open file, and return array
    :param file_path: Path to maze file
    :return:
    """
    with open(file_path, "r") as file:
        file_data = file.readlines()
    return file_data


def format_maze_file(file):
    """
    Replace strings to integers,
    prepare for matrix
    :param file: Maze file
    :return: format_maze: Maze with integers
    :return: start: Coordinate for start maze
    :return: end: Coordinate for finish maze
    """
    format_maze = []
    start, end = (0, 0), (0, 0)
    for row_num, _line in enumerate(file):
        if "I" in _line:
            start = (row_num, _line.index("I"))
            _line = _line.replace("I", " ")
        if "E" in _line:
            end = (row_num, _line.index("E"))
            _line = _line.replace("E", " ")

        _line = _line.replace("0", "1")
        _line = _line.replace(" ", "0")

        maze_row = list(map(int, list(_line[:-1])))
        format_maze.append(maze_row)
    return format_maze, start, end


def create_maze_matrix(maze, start=(0, 0)):
    """
    Create matrix from maze array, with start coordinate
    :param maze: array
    :param start: start coordinate
    :return: matrix with start coordinate
    """
    m_matrix = []
    for i in range(len(maze)):
        m_matrix.append([])
        for j in range(len(maze[i])):
            m_matrix[-1].append(0)
    i, j = start
    m_matrix[i][j] = 1
    return m_matrix


def make_step(k, maze, maze_matrix):
    """
    Steps in maze
    :param k: step number
    :param maze: maze array
    :param maze_matrix: maze matrix
    """
    for i in range(len(maze_matrix)):
        for j in range(len(maze_matrix[i])):
            if maze_matrix[i][j] == k:
                if i > 0 and maze_matrix[i - 1][j] == 0 and maze[i - 1][j] == 0:
                    maze_matrix[i - 1][j] = k + 1
                if j > 0 and maze_matrix[i][j - 1] == 0 and maze[i][j - 1] == 0:
                    maze_matrix[i][j - 1] = k + 1
                if (
                    i < len(maze_matrix) - 1
                    and maze_matrix[i + 1][j] == 0
                    and maze[i + 1][j] == 0
                ):
                    maze_matrix[i + 1][j] = k + 1
                if (
                    j < len(maze_matrix[i]) - 1
                    and maze_matrix[i][j + 1] == 0
                    and maze[i][j + 1] == 0
                ):
                    maze_matrix[i][j + 1] = k + 1


def find_finish(maze, maze_matrix, end):
    """
    Find finish with maze matrix,
    with loop steps
    :param maze:
    :param maze_matrix:
    :param end: finish coordinate
    """
    k = 0
    while maze_matrix[end[0]][end[1]] == 0:
        k += 1
        make_step(k, maze, maze_matrix)


def find_path(maze_matrix, end):
    """
    Construct path coordinate
    :param maze_matrix:
    :param end: end coordinate, starts from end
    :return: path array of tuples
    """
    i, j = end
    k = maze_matrix[i][j]
    the_path = [(i, j)]
    while k > 1:
        if i > 0 and maze_matrix[i - 1][j] == k - 1:
            i, j = i - 1, j
            the_path.append((i, j))
            k -= 1
        elif j > 0 and maze_matrix[i][j - 1] == k - 1:
            i, j = i, j - 1
            the_path.append((i, j))
            k -= 1
        elif i < len(maze_matrix) - 1 and maze_matrix[i + 1][j] == k - 1:
            i, j = i + 1, j
            the_path.append((i, j))
            k -= 1
        elif j < len(maze_matrix[i]) - 1 and maze_matrix[i][j + 1] == k - 1:
            i, j = i, j + 1
            the_path.append((i, j))
            k -= 1
    return the_path


def write_path(the_path, start, end, maze):
    """
    Write path on maze with '@'
    :param the_path: Path array
    :param start: Start coordinate
    :param end: Finish coordinate
    :param maze:
    :return: Maze with path '@'
    """
    for ia, ib in the_path:
        if (ia, ib) == end:
            maze[ia][ib] = "E"
        elif (ia, ib) == start:
            maze[ia][ib] = "|"
        else:
            maze[ia][ib] = "@"
    return maze


def write_maze_to_file(file_path, maze):
    """
    Write maze to file with
    replace 0 to space,
    replace 1 to 0
    """
    with open(file_path, "w") as f:
        for line in maze:
            new_line = "".join([*map(str, line)]).replace("0", " ").replace("1", "0")
            new_line += "\n"
            f.write(new_line)


def parse_args():
    """
    Args from command line,
    Input file, and output file
    """
    parser = argparse.ArgumentParser(description="Maze path finder.")
    parser.add_argument(
        "--input",
        dest="input_file",
        type=str,
        help="Input maze file",
        required=True,
    )
    parser.add_argument(
        "--output",
        dest="output_file",
        type=str,
        help="Output maze with path",
        required=True,
    )

    args = parser.parse_args()
    return args.input_file, args.output_file


def main():
    """
    Main call
    """
    input_file, output_file = parse_args()
    maze_file = open_maze(input_file)
    maze, start, end = format_maze_file(maze_file)
    maze_matrix = create_maze_matrix(maze, start)
    find_finish(maze, maze_matrix, end)
    path = find_path(maze_matrix, end)
    write_path(path, start, end, maze)
    write_maze_to_file(output_file, maze)


if __name__ == "__main__":
    main()
