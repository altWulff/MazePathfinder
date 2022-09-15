--[[
Pathfinder in maze
catch txt file and return file
with maze path
]]--

local argparse = require "lib/argparse"


local function open_maze(file_path)
    -- Open file, and return array
    -- :param file_path: Path to maze file
    io.input(file_path)
    maze_table = {}

    for line in io.lines() do
        table.insert(maze_table, tostring(line))
    end
    return maze_table
end


local function format_maze_file(file)
    -- Replace strings to integers,
    -- prepare for matrix
    -- :param file: Maze file
    -- :return: format_maze: Maze with integers
    -- :return: start: Coordinate for start maze
    -- :return: finish: Coordinate for finish maze
    format_maze = {}

    for row_num, _line in ipairs(maze_table) do
        if string.find(_line, "I") then
            start = {row_num, string.find(_line, "I")}
            _line = string.gsub(_line, "I", " ")
        elseif string.find(_line, "E") then
            finish = {row_num, string.find(_line, "E")}
            _line = string.gsub(_line, "E", " ")
        end
        _line = string.gsub(_line, "0", "1")
        _line = string.gsub(_line, " ", "0")

        local t = {}
        for i = 1, #_line do
            t[i] = _line:sub(i, i)
        end
        table.insert(format_maze, t)
    end
    return format_maze, start, finish
end


local function create_maze_matrix(maze, start)
    -- Create matrix from maze array, with start coordinate
    -- :param maze: array
    -- :param start: start coordinate
    -- :return: matrix with start coordinate

    m_matrix = {}
    for i=1, #maze do
        m_matrix[i] = {}
        for j=1, #maze[i] do
            m_matrix[i][j] = 0
        end
    end
    m_matrix[start[1]][start[2]] = 1
    return m_matrix
end


function make_step(k)
    -- Steps in maze
    -- :param k: step number

    for i=1, #maze_matrix do
        for j=1, #maze_matrix[i] do
            if maze_matrix[i][j] == k then
                if i > 1 and (maze_matrix[i - 1][j]) == 0 and tonumber(maze[i - 1][j]) == 0 then
                    maze_matrix[(i - 1)][j] = (k + 1)
                end
                if j > 1 and (maze_matrix[i][j - 1]) == 0 and tonumber(maze[i][j - 1]) == 0 then
                    maze_matrix[i][(j - 1)] = (k + 1)
                end
                if (i < #maze_matrix and (maze_matrix[i + 1][j] == 0) and tonumber(maze[i + 1][j]) == 0) then
                    maze_matrix[(i + 1)][j] = (k + 1)
                end

                if (j < (#maze_matrix[i]) - 1
                    and maze_matrix[i][j + 1] == 0
                    and tonumber(maze[i][j + 1] ) == 0) then
                    maze_matrix[i][(j + 1)] = (k + 1)
                end
            end
        end
    end
end


function find_finish()
    -- Find finish with maze matrix,
    -- with loop steps

    k = 0
    while maze_matrix[finish[1]][finish[2]-1] == 0 do
        k = (k + 1)
        make_step(k)
    end
end


function find_path()
    -- Construct path coordinate
    -- :return: path array of tuples

    local i, j = finish[1], finish[2]
    local k = maze_matrix[i][j - 1] + 1
    local the_path = {finish}
    while k > 0 do
        if ((i > 1) and (maze_matrix[(i - 1)][j] == k - 1 )) then
            i, j = (i - 1), j
            table.insert(the_path, {i, j})
            k = (k - 1)
        elseif ((j > 1) and (maze_matrix[i][(j - 1)] == (k - 1))) then
            i, j = i, (j - 1)
            table.insert(the_path, {i, j})
            k = (k - 1)
        elseif ((i < #maze_matrix) and (maze_matrix[(i + 1)][j] == (k - 1))) then
            i, j = (i + 1), j
            table.insert(the_path, {i, j})
            k = (k - 1)
        elseif ((j < #maze_matrix[i]) and (maze_matrix[i][(j + 1)] == (k - 1))) then
            i, j = i, (j + 1)
            table.insert(the_path, {i, j})
            k = (k - 1)
        else
            break
        end
    end
    table.remove(the_path, #the_path)
    return the_path
end


function write_path(the_path, start, finish, maze)
    -- Write path on maze with '@'
    -- :param the_path: Path array
    -- :param start: Start coordinate
    -- :param end: Finish coordinate
    -- :param maze:
    -- :return: Maze with path '@'

    for i=1, #the_path do
        local ia = the_path[i][1]
        local ib = the_path[i][2]
        if ia == finish[1] and ib == finish[2] then
             maze[ia][ib] = "E"
        elseif ia == start[1] and ib == start[2] then
            maze[ia][ib] = "|"
        else
            maze[ia][ib] = "@"
        end
    end
    return maze
end


local function write_maze_to_file(file_path, maze)
    -- Write maze to file with
    -- replace 0 to space,
    -- replace 1 to 0

    local f = io.open(file_path, "w")
    for i=1, #maze do
        for j=1, #maze[i] do
            local _line = tostring(maze[i][j])
            local _line = _line.."\n"
            local _line = string.gsub(_line, "0", " ")
            local _line = string.gsub(_line, "1", "0")
            f:write(_line)
        end
    end
    f:close()
end

local function parse_args()
    -- Args from command line,
    -- Input file, and output file

    local parser = argparse("main", "Maze path finder")
    parser:option("-i --input", "Input maze file")
    parser:option("-o --output", "Output maze with path")
    local args = parser:parse()
    return args.input, args.output
end


local function main()
    -- Main call

    input_file, output_file = parse_args()
    maze_file = open_maze(input_file)
    maze, start, finish = format_maze_file(maze_file)
    maze_matrix = create_maze_matrix(maze, start)

    find_finish()
    path = find_path()
    maze = write_path(path, start, finish, maze)

    for i=1, #maze do
        maze_pr = ""
        for j=1, #maze[i] do
            _line = tostring(maze[i][j])
            _line = string.gsub(_line, "0", " ")
            _line = string.gsub(_line, "1", "0")
            maze_pr = maze_pr.."".._line..""
        end
        print(maze_pr)
    end
    write_maze_to_file(output_file, maze)
end


main()
