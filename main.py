import sys, os
from terminal_colors import red_color, yellow_color, blue_color, reset_color 
from utilities import is_number, remove_suffix 
from typing import List
from plotter import plot
from coord_converter import process_conversion


# command line arguments
argv = sys.argv
argc = len(argv)

def parse_file(cbox_file_path: str, min_confidence: float, output_dir_path: str, max_lines = 1000):
  process_conversion([cbox_file_path], "box", "box")

  """
  Parses the given file, filtering out non-entry lines (lines that do not start with a number) and entries with a confidence less than the confidence given.

  Writes new entries, but only with the x and y coordinates, image width and height, and confidence, to a new file with same name as given file but in given output directory.

  Args:
    `cbox_file_path`: the file to parse.
    `min_confidence`: the threshhold for confidence of filtered entries
    `output_dir_path`: the location of the folder in which parsed files are stored
    `max_lines`: the maximum number of lines to filter from the file
  """

  # safety check, make sure that input file exists
  if not os.path.isfile(cbox_file_path):
    print("File not found: " + cbox_file_path + ". No changes made.")
    return

  print(yellow_color, "Parsing", cbox_file_path.split("/")[-1], reset_color)

  # open file
  file = open(cbox_file_path, "r")

  # output file location
  if not os.path.isdir(output_dir_path):
    print(output_dir_path)
    os.makedirs(output_dir_path)
  if output_dir_path[-1] != "/":
    output_dir_path = output_dir_path + "/"

  # make sure output file has extension ".cbox"
  cbox_file_path = remove_suffix(cbox_file_path, cbox_file_path.split(".")[-1])
  cbox_file_path += "cbox"
  output_file = open(output_dir_path + cbox_file_path.split("/")[-1], "w")

  count = 0
  all_x: List[float] = []
  all_y: List[float] = []

  # parse file
  for line in file:
    words = line.split()

    is_cryolo_sphire_formatted = len(words) >= 11 and is_number(words[0]) and is_number(words[1]) and is_number(words[3]) and is_number(words[4]) and is_number(words[8])

    if len(words) < 2 or not is_number(words[0]) or not is_number(words[1]):
      continue
    if is_cryolo_sphire_formatted and float(words[8]) < min_confidence:
      continue

    # indices are based on output of cryolo_predict.
    x = words[0]
    y = words[1]
    width = words[3] if is_cryolo_sphire_formatted else "100"
    height = words[4] if is_cryolo_sphire_formatted else "100"
    confidence = words[8] if is_cryolo_sphire_formatted else "1.0"

    # check for overlap with existing rectangles
    overlap = False

    # for i in range(len(all_x)):
    #   if abs(all_x[i] - float(x)) < float(width):
    #     overlap = True
    #     break
    #   if abs(all_y[i] - float(y)) < float(height):
    #     overlap = True
    #     break

    if overlap:
      continue
    else:
      all_x.append(float(x))
      all_y.append(float(y))

    # write to output file
    output_file.write(" ".join([x,y,width,height,confidence]))
    output_file.write("\n")

    count += 1

    if count >= max_lines:
      break

  # close files
  file.close()
  output_file.close()

  return


def main():
  """
  Command line arguments:
    `argv[1]`: Location of .mrc file(s)
    `argv[2]`: Location of .box file(s)
    `argv[3]`: Location of output for parsed .box files
    `argv[4]`: Location of output for annotated images
  
  Parses given .box files and annotates image(s) in .mrc file(s) with parsed files.
  """

  mrc_file_path: str = input(blue_color + "Path to .mrc file or directory of files:\n" + reset_color) if argc < 2 else argv[1]
  cbox_file_path: str = input(blue_color + "Path to .cbox file or directory of files (default is ~/parser_output/):\n" + reset_color) if argc < 3 else argv[2]
  parser_output_dir = "parser_output/" if argc < 4 else argv[3]
  plot_output_dir = "annotated_images/" if argc < 5 else argv[4]

  # append "/" to avoid "directory does not exist" errors
  if parser_output_dir[-1] != "/":
    parser_output_dir = parser_output_dir + "/"
  if plot_output_dir[-1] != "/":
    plot_output_dir = plot_output_dir + "/"

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
    plot(mrc_file_path, parser_output_dir, None, plot_output_dir)
  elif os.path.isdir(mrc_file_path):
    for filename in os.listdir(mrc_file_path):
      file_path = os.path.join(mrc_file_path, filename)
      plot(file_path, parser_output_dir, "/home/tl699/cryolo-sphire/parser_output/EMPIAR-10017_expected/", plot_output_dir)
  else:
    print(red_color + "Error: file/folder does not exist: " + mrc_file_path + reset_color, file=sys.stderr)
    return
  
  return


if __name__ == "__main__":
  main()