class SevenSegments:

    def __init__(self):
        self.inputs = self.read()

    def read(self):
        with open("input.txt", "r") as f:
            return f.readlines()
    
    def decode(self, input):
        entries = input.split()
        entries.sort(key=lambda x: len(x))
        decode = {}
        partially_decoded = {}        
        for entry in entries:
            next_level_entries = [next for next in entries if len(next) == len(entry) + 1]
            print(next_level_entries)

    
    def process(self):
        for entry in self.inputs:
            input, output = entry.split(' | ')
            self.decode(input)

        


if __name__ == "__main__":
    code = SevenSegments()
    code.process()
    