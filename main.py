import sys, os
import mrcfile
import matplotlib.colors as mcolors
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import numpy as np
import cv2
from typing import List, Union


# command line arguments
argv = sys.argv
argc = len(argv)

# ANSI escape sequence for terminal colors!
red_color = "\033[91m"
yellow_color = "\033[33m"
green_color = "\033[32m"
blue_color = "\033[34m"

# ANSI escape sequence for resetting text color
reset_color = '\033[0m'


def equalize_image(image_data: np.ndarray):
  # Convert to uint8 data type
  normalized_image = (image_data - np.min(image_data)) / (np.max(image_data) - np.min(image_data))
  casted_image = (normalized_image * 255).astype(np.uint8)

  # Apply histogram equalization and convert back to original data type (float)
  equalized_image = cv2.equalizeHist(casted_image)
  equalized_image = equalized_image.astype(np.float32) / 255.0

  return equalized_image


def is_number(string):
  """
  Helper function used to determine if a string is a number.
  """
  try:
    float(string)
    return True
  except ValueError:
    return False


def remove_suffix(string: str, suffix: str) -> str:
  """
  Helper function that returns the result of removing a suffix from a string.
  """
  if string[len(string) - len(suffix):] == suffix:
    return string[:-len(suffix)]
  else:
    return string


def matplotlib_add_rects(cbox_file_path: str, ax: plt.Axes, r: int, g: int, b: int):
  """
  Helper function to annotate(). Adds boxes from given cbox file to matplotlib image axes.
  """
  cbox_file = open(cbox_file_path, "r")

  # annotate image, adding boxes specified by cbox file
  for line in cbox_file:
    words = line.split()

    if len(words) < 4:
      continue
    if not is_number(words[0]) or not is_number(words[1]) or not is_number(words[2]) or not is_number(words[3]):
      continue

    width = float(words[2])
    height = float(words[3])
    x = float(words[0]) - width / 2
    y = float(words[1]) - height / 2
    confidence = float(words[4]) if (len(words) >= 5 and is_number(words[4])) else 1.0

    rect = plt.Rectangle((x,y), width, height, edgecolor=(r,g,b, confidence), linewidth=0.5, fill=False)
    ax.add_patch(rect)

  cbox_file.close()


def annotate(image_data: np.ndarray, cbox_file_path: str, expected_cbox_file_path: Union[str, None], output_dir_path: str):
  """
  Helper function to plot(). Annotates image data with given cbox file using matplotlib, and stores annotated image in given output directory.
  """
  if not os.path.isfile(cbox_file_path):
    print("File not found: " + cbox_file_path + ". No changes made.")
    return

  if expected_cbox_file_path != None and not os.path.isfile(expected_cbox_file_path):
    print("File not found: " + expected_cbox_file_path + ". No changes made.")
    return

  if not os.path.isdir(output_dir_path):
    os.makedirs(output_dir_path)
  if output_dir_path[-1] != "/":
    output_dir_path = output_dir_path + "/"

  # load image into matplotlib
  fig, ax = plt.subplots()
  ax.set_aspect('equal')
  ax.imshow(image_data, cmap='gray', aspect="auto")

  # Create a colorbar using a custom color map
  colors = [(1, 0, 0, 0), (1, 0, 0, 1)]
  cmap = mcolors.LinearSegmentedColormap.from_list('custom_red', colors, N=256)
  cbar = plt.colorbar(cm.ScalarMappable(cmap=cmap), ax=ax)
  cbar.set_ticks([0, 1])
  cbar.ax.set_yticklabels(['Less confident', 'More confident'])

  matplotlib_add_rects(cbox_file_path, ax, 0.3, 0.2, 1)

  if expected_cbox_file_path != None:
    matplotlib_add_rects(expected_cbox_file_path, ax, 0.8, 0, 0)

  # save figure to output directory
  plt.savefig(output_dir_path + remove_suffix(cbox_file_path.split("/")[-1], ".cbox") + ".png", dpi=600)

  # close plot
  plt.close()
  
  return


def plot(mrc_file_path: str, cbox_dir_path: str, expected_cbox_dir_path: Union[str, None], output_dir_path: str):
  """
  Adds annotations (boxes) to image(s) in .mrc file specified by given path.

  Args:
    `mrc_file_path`: the .mrc file to annotate
    `cbox_dir_path`: the location of folder containing predicted .cbox files
    `expected_dir_path` (Optional): the location folder containg expected .cbox files
    `output_dir_path`: the location of the folder in which annotated images are stored

  NOTE: the file name(s) in cbox_dir_path must be the same as the file name(s) in mrc_file_path.
  """
  if not os.path.isfile(mrc_file_path):
    print("File not found: " + mrc_file_path)
    return

  if not os.path.isdir(cbox_dir_path):
    print("Folder not found: " + cbox_dir_path)
    return

  if expected_cbox_dir_path != None and not os.path.isdir(expected_cbox_dir_path):
    print("Folder not found: " + expected_cbox_dir_path)
    return
  
  if not mrc_file_path.endswith(".mrc"):
    print("File does not end with '.mrc' or other image formats: " + mrc_file_path)
    return

  mrc_file = mrcfile.open(mrc_file_path)
  data = mrc_file.data
  mrc_file_name = mrc_file_path.split("/")[-1]

  if len(data.shape) > 2:
    for i, image_data in enumerate(data):
      cbox_file_name = remove_suffix(mrc_file_name, ".mrc") +  "_slice" + "{:04d}".format(i) + ".cbox"
      cbox_file_path = cbox_dir_path + cbox_file_name
      expected_cbox_file_path = expected_cbox_dir_path + cbox_file_name

      equalized_image = equalize_image(image_data)
      print(green_color, "Annotating", mrc_file_name, "(", i + 1, "/", len(data), ")", reset_color)
      annotate(equalized_image, cbox_file_path, expected_cbox_file_path, output_dir_path)
  else:
    cbox_file_path = cbox_dir_path + remove_suffix(mrc_file_name, ".mrc") + ".cbox"
    expected_cbox_file_path = expected_cbox_dir_path + remove_suffix(mrc_file_name, ".mrc") + ".cbox"
    
    equalized_image = equalize_image(data)
    print(green_color, "Annotating", mrc_file_name, "(1/1)", reset_color)
    annotate(equalized_image, cbox_file_path, expected_cbox_file_path, output_dir_path)


  mrc_file.close()
  return


def parse_file(cbox_file_path: str, min_confidence: float, output_dir_path: str, max_lines = 1000):
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
    # width = words[3] if is_cryolo_sphire_formatted else "100"
    # height = words[4] if is_cryolo_sphire_formatted else "100"
    width = "100"
    height = "100"
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