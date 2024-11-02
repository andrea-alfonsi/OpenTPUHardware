#!/usr/bin/env python3
import argparse
import os
import re

def string_to_number(string):
    multipliers = {
      'K': 1024,
      'M': 1024 * 1024,
      'G': 1024 * 1024 * 1024,
      'T': 1024 * 1024 * 1024 * 1024
    }
    if ( string[-1] in multipliers ):
      return int( string[:-1] ) * multipliers[string[-1]]
    return int( string )

def main():
  parser = argparse.ArgumentParser(
      prog='GenerateEmptyMemory',
      description='Generates a text file of the given dimension that can be loaded into memories'
    )
  parser.add_argument('-s', '--size', help="The total size in  bits that can be stored in the memory", required=True)
  parser.add_argument('-c', '--chunk', help="The length of each block")
  parser.add_argument('-o', '--output', help="Set the name of the output file. Default: memory_SIZE_CHUNK.mem", default="memory_{SIZE}_{CHUNK}.mem")
  args = parser.parse_args()
  current_dir = os.getcwd()
  chunk_size = string_to_number( args.chunk ) if args.chunk is not None else string_to_number( args.size )
  memory = ' '.join(re.findall(f"\d{{{chunk_size}}}", ('0' * string_to_number( args.size )) ))

  with open( args.output.format(SIZE = string_to_number(args.size), CHUNK=chunk_size ), 'w') as f:
    f.write( memory )
  

if __name__ == "__main__":
  try:
    main()
  except Exception as e:
    print('An error occurred: ', end='')
    print( e )