from functools import reduce

class SmokeBasin:
    input_file = "./input.txt"

    def __init__(self):
        self.matrix = [[]]
        self.read()
        self.low_points = {}
        self.basin = {}

    def read(self):
        with open(self.input_file) as f:
            inputs = [x.strip() for x in f.readlines()]
        self.matrix = [[-1 for column in range(len(inputs[0]))] for row in range(len(inputs))] 
        for row_num in range(0, len(inputs)):
            entries = [int(x) for x in inputs[row_num]]
            for column_num in range(0, len(entries)):
                self.matrix[row_num][column_num] = int(entries[column_num])
    
    def get_top(self, row, col):
        return self.matrix[row-1][col] if row > 0 else 10
    
    def get_left(self, row, col):
        return self.matrix[row][col-1] if col > 0 else 10
    
    def get_bottom(self, row, col):
        return self.matrix[row+1][col] if row < len(self.matrix) - 1 else 10
    
    def get_right(self, row, col):
        return self.matrix[row][col+1] if col < len(self.matrix[0]) - 1 else 10
    
    def get_adjacent(self, row, col):
        return [
            self.get_top(row, col),
            self.get_left(row, col),
            self.get_bottom(row, col),
            self.get_right(row, col),
        ]
            
    def process_1(self):
        for row_num in range(0, len(self.matrix)):
            for column_num in range(0, len(self.matrix[row_num])):
                entry = self.matrix[row_num][column_num]
                adjacent = self.get_adjacent(row_num, column_num)
                if entry < min(adjacent):
                    self.low_points[(row_num, column_num)] = entry
        print(sum([x + 1 for x in self.low_points.values()]))
    
    def traverse(self, row, col, visited):
        if row < 0 or row > len(self.matrix) - 1:
            return visited
        if col < 0 or col > len(self.matrix[0]) - 1:
            return visited
        if (row, col) in visited:
            return visited
        if self.matrix[row][col] == 9:
            return visited
       
        visited[(row, col)] = self.matrix[row][col]
        self.traverse(row+1, col, visited)
        self.traverse(row-1, col, visited)
        self.traverse(row, col+1, visited)
        self.traverse(row, col-1, visited)
        return visited
    
    def process_2(self):
        for (row, column) in self.low_points:
            self.basin[(row, column)] = len(self.traverse(row, column, {}))
        print(reduce((lambda x, y: x * y), sorted(self.basin.values(), reverse=True)[:3]))


if __name__ == '__main__':
    sb = SmokeBasin()
    sb.process_1()
    sb.process_2()
