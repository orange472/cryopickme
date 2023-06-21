import os
import mrcfile
import matplotlib.colors as mcolors
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import numpy as np
from histogram_equalization import equalize_image
from utilities import is_number, remove_suffix
from terminal_colors import green_color, reset_color
from typing import Union

def matplotlib_add_rects(cbox_file_path: str, ax: plt.Axes, r: float, g: float, b: float):
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

    rect = plt.Rectangle((x,y), width, height, edgecolor=(r,g,b, confidence), linewidth=0.5, fill=False) # type: ignore
    ax.add_patch(rect)

  cbox_file.close()


def annotate(image_data: np.ndarray, cbox_file_path: str, expected_cbox_file_path: Union[str, None], output_dir_path: str):
  """
  Helper function to plot(). Annotates image data with given box file using matplotlib, and stores annotated image in given output directory.
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
  data = (np.ndarray)(data)
  mrc_file_name = mrc_file_path.split("/")[-1]

  if len(data.shape) > 2:
    for i, image_data in np.ndenumerate(data):
      cbox_file_name = remove_suffix(mrc_file_name, ".mrc") +  "_slice" + "{:04d}".format(i) + ".cbox"
      cbox_file_path = cbox_dir_path + cbox_file_name
      expected_cbox_file_path = None if expected_cbox_dir_path == None else expected_cbox_dir_path + cbox_file_name

      equalized_image = equalize_image(image_data)
      print(green_color, "Annotating", mrc_file_name, "(", i + 1, "/", len(data), ")", reset_color)
      annotate(equalized_image, cbox_file_path, expected_cbox_file_path, output_dir_path)
  else:
    cbox_file_path = cbox_dir_path + remove_suffix(mrc_file_name, ".mrc") + ".cbox"
    expected_cbox_file_path = None if expected_cbox_dir_path == None else expected_cbox_dir_path + remove_suffix(mrc_file_name, ".mrc") + ".cbox"
    
    equalized_image = equalize_image(data)
    print(green_color, "Annotating", mrc_file_name, "(1/1)", reset_color)
    annotate(equalized_image, cbox_file_path, expected_cbox_file_path, output_dir_path)


  mrc_file.close()
  return