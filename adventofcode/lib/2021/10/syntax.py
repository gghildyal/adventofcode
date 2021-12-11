from collections import deque

class SyntaxScoring:
    input_file = "./input.txt"
    values = {
        ")": 3,
        "]": 57,
        "}": 1197,
        ">": 25137,
    }
    pairs = {
        "(": ")",
        "[": "]",
        "{": "}",
        "<": ">"
    }

    def __init__(self):
        self.read()
        self.scores = {}

    def read(self):
        with open(self.input_file) as f:
            self.inputs = [x.strip() for x in f.readlines()]

    def is_opening(self, char):
        return char in self.pairs
    
    def traverse(self, line):
        stack = deque([])
        for char in line:
            if self.is_opening(char):
                stack.append(char)
                continue
            if not stack:
                return stack, char
            if char != self.pairs[stack[-1]]:
                return stack, char
            stack.pop()
        return stack, None

    def process_1(self):
        score = 0
        for line in self.inputs:
            _, syntax_error = self.traverse(line)
            if syntax_error:
                score += self.values[syntax_error]
        print(score)

    def process_2(self):
        score = 0
        for line in self.inputs:
            _, syntax_error = self.traverse(line)
            if syntax_error:
                score += self.values[syntax_error]
        print(score)

if __name__ == '__main__':
    sb = SyntaxScoring()
    sb.process_1()
