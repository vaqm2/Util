#!/usr/bin/env python

import sys

def main():
    sumstats = sys.argv[1]
    fh = open(sumstats, 'r')
    even_out = open(sys.argv[2] + "even.txt", 'w')
    odd_out = open(sys.argv[2] + "odd.txt", 'w')

    for line in fh:
        if(line.startswith("CHR")):
            even_out.write(line)
            odd_out.write(line)
        else:
            lineContents = line.split()
            chromosome = lineContents[0]
            if chromosome.isnumeric():
                chromosome = int(chromosome)
                if(chromosome % 2 == 0):
                    even_out.write(line)
                else:
                    odd_out.write(line)
            else:
                sys.stdout("Skipping non-autosomes: " + line)

    fh.close()
    even_out.close()
    odd_out.close()


if __name__ == '__main__':
    main()