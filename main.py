import sys, os
from terminal_colors import red_color, yellow_color, blue_color, reset_color 
from utilities import is_number, remove_suffix 
from typing import List
from plotter import plot
from coord_converter import process_conversion
import argparse


# command line arguments
argv = sys.argv
argc = len(argv)

def parse_file(file_path: str, min_confidence: float, output_dir_path: str, max_lines = 1000):
  """
  Parses the given file, filtering out non-entry lines (lines that do not start with a number) and entries with a confidence less than the confidence given.

  Writes new entries, but only with the x and y coordinates, image width and height, and confidence, to a new file with same name as given file but in given output directory.

  Args:
    `file_path`: the file to parse.
    `min_confidence`: the threshhold for confidence of filtered entries
    `output_dir_path`: the location of the folder in which parsed files are stored
    `max_lines`: the maximum number of lines to filter from the file
  """

  # safety check, make sure that input file exists
  if not os.path.isfile(file_path):
    print("File not found: " + file_path + ". No changes made.")
    return
  else:
    print(yellow_color, "Parsing", file_path.split("/")[-1], reset_color)

  # safety check, make sure that file format is valid
  file_extension: str = file_path.split(".")[-1] if len(file_path.split("/")[-1].split(".")) > 1 else "box"

  if file_extension != "box" and file_extension != "cbox" and file_extension != "star" and file_extension != "tsv":
    print("Invalid file format.")
    return

  # output file location
  if not os.path.isdir(output_dir_path):
    os.makedirs(output_dir_path)

  if output_dir_path[-1] != "/":
    output_dir_path = output_dir_path + "/"

  # make sure output file has extension ".box"
  if len(file_path.split(".")) > 1:
    output_file_path = remove_suffix(file_path, file_path.split(".")[-1])
  else:
    output_file_path = file_path + ".box"

  output_file = open(output_dir_path + output_file_path.split("/")[-1], "w")

  # * convert file to box format
  out_dfs = process_conversion([file_path], file_extension, "box", out_dir=None)
  out_df = list(out_dfs.values())[0]
  boxes = list(out_df.itertuples(name="Box", index=False))

  for box in boxes:
    x,y,w,h = round(box.x), round(box.y), round(box.w), round(box.h)
    output_file.write(" ".join([str(x),str(y),str(w),str(h)]))
    output_file.write("\n")
  
  output_file.close()

  return


def main():
  """
  Command line arguments:
    `argv[1]`: Location of .mrc file(s)
    `argv[2]`: Location of .box file(s)
    `argv[3]`: Location of output for parsed .box files
    `argv[4]`: Location of output for annotated images
    `argv[5]`: Location of expected annotations
    `argv[6]`: Box size override
  
  Parses given .box files and annotates image(s) in .mrc file(s) with parsed files.
  """

  parser = argparse.ArgumentParser()
  parser.add_argument("mrc_files", type=str, help="Path to .mrc files")
  parser.add_argument("predicted", type=str, help="Path to predicted annotations")
  parser.add_argument("--expected", type=str, nargs='?', const=None, help="Path to expected annotations")
  parser.add_argument("--parser_output", type=str, nargs='?', const="parser_output", help="Path to output parsed annotations")
  parser.add_argument("--plotter_output", type=str, nargs='?', const="plotter_output", help="Path to output annotated images")
  parser.add_argument("--box_size", type=int, nargs='?', const=0, help="Manual override of box sizes")

  args = parser.parse_args()

  mrc_file_path: str = args.mrc_files
  cbox_file_path: str = args.predicted
  expected_dir = args.expected
  parser_output_dir = args.parser_output
  plot_output_dir = args.plotter_output
  box_size = args.box_size

  # append "/" to avoid "directory does not exist" errors
  if parser_output_dir[-1] != "/":
    parser_output_dir = parser_output_dir + "/"
  if plot_output_dir[-1] != "/":
    plot_output_dir = plot_output_dir + "/"

  if(not os.path.isdir(parser_output_dir)):
    os.mkdir(parser_output_dir)
  if(not os.path.isdir(plot_output_dir)):
    os.mkdir(plot_output_dir)

  # parse each .cbox file
  if os.path.isfile(cbox_file_path):
    parse_file(cbox_file_path, 0.2, parser_output_dir)
  elif os.path.isdir(cbox_file_path):
    for filename in os.listdir(cbox_file_path):
      file_path = os.path.join(cbox_file_path, filename)
      parse_file(file_path, 0.2, parser_output_dir)
  else:
    print(red_color + "Error: file/folder does not exist: " + cbox_file_path + reset_color, file=sys.stderr)
    return

  # annotate each image slice of each .mrc file using the .cbox files which should now be in "parser_output/"
  if os.path.isfile(mrc_file_path):
    plot(mrc_file_path, parser_output_dir, expected_dir, plot_output_dir, box_size)
  elif os.path.isdir(mrc_file_path):
    for filename in os.listdir(mrc_file_path):
      file_path = os.path.join(mrc_file_path, filename)
      plot(file_path, parser_output_dir, expected_dir, plot_output_dir, box_size)
  else:
    print(red_color + "Error: file/folder does not exist: " + mrc_file_path + reset_color, file=sys.stderr)
    return
  
  return


if __name__ == "__main__":
  main()