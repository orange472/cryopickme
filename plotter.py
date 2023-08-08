import os
import mrcfile
import matplotlib.colors as mcolors
import matplotlib.pyplot as plt
import matplotlib.cm as cm
import matplotlib.patches as mpatches
import numpy as np
from PIL import Image
from histogram_equalization import equalize_image
from utilities import is_number, remove_suffix
from terminal_colors import green_color, reset_color
from typing import Union

def matplotlib_add_rects(cbox_file_path: str, ax: plt.Axes, r: float, g: float, b: float, box_size, offset = True):
  """
  Helper function to annotate(). Adds boxes from given cbox file to matplotlib image axes.
  """
  cbox_file = open(cbox_file_path, "r")

  # annotate image, adding boxes specified by cbox file
  for line in cbox_file:
    words = line.split()

    if len(words) < 2:
      continue
    if not is_number(words[0]) or not is_number(words[1]):
      continue

    width = box_size if box_size > 0 else float(words[2]) if len(words) >= 4 and is_number(words[2]) else 100
    height = box_size if box_size > 0 else float(words[3]) if len(words) >= 4 and is_number(words[3]) else 100
    x = float(words[0]) - width / 2 if offset else float(words[0])
    y = float(words[1]) - height / 2 if offset else float(words[1])
    confidence = float(words[4]) if (len(words) >= 5 and is_number(words[4])) else 1.0

    rect = plt.Rectangle((x,y), width, height, edgecolor=(r,g,b, confidence), linewidth=0.5, fill=False) # type: ignore
    ax.add_patch(rect)

  cbox_file.close()


def annotate(image_data: np.ndarray, cbox_file_path: str, expected_cbox_file_path: Union[str, None], output_dir_path: str, box_size):
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
  # colors = [(1, 0, 0, 0), (1, 0, 0, 1)]
  # cmap = mcolors.LinearSegmentedColormap.from_list('custom_red', colors, N=256)
  # cbar = plt.colorbar(cm.ScalarMappable(cmap=cmap), ax=ax)
  # cbar.set_ticks([0, 1])
  # cbar.ax.set_yticklabels(['Less confident', 'More confident'])

  matplotlib_add_rects(cbox_file_path, ax, 1, 0, 0, box_size)

  if expected_cbox_file_path != None:
    matplotlib_add_rects(expected_cbox_file_path, ax, 0, 1, 0, box_size, False)

  # Legend
  predicted_legend_patch = mpatches.Patch(color=(1, 0, 0), label='predicted')
  expected_legend_patch = mpatches.Patch(color=(0, 1, 0), label='labeled')
  plt.legend(loc = "upper right", fontsize = "small", bbox_to_anchor =  (0.13, 1.06), handles=[expected_legend_patch, predicted_legend_patch])

  # save figure to output directory
  plt.savefig(output_dir_path + cbox_file_path.split("/")[-1].split(".")[0] + ".png", dpi=400)

  # close plot
  plt.close()
  
  return


def plot(image_path: str, predicted_dir_path: str, expected_dir_path: Union[str, None], output_dir_path: str, box_size = 0):
  """
  Adds annotations (boxes) to image(s) in .mrc file specified by given path.

  Args:
    `image_path`: the .mrc file to annotate
    `predicted_dir_path`: the location of folder containing annotations
    `expected_dir_path` (Optional): the location folder containg expected .cbox files
    `output_dir_path`: the location of the folder in which annotated images are stored

  NOTE: the file name(s) in predicted_dir_path must be the same as the file name(s) in image_path.
  """
  if not os.path.isfile(image_path):
    print("File not found: " + image_path)
    return

  if not os.path.isdir(predicted_dir_path):
    print("Folder not found: " + predicted_dir_path)
    return

  if expected_dir_path != None and not os.path.isdir(expected_dir_path):
    print("Folder not found: " + expected_dir_path)
    return

  if image_path.endswith(".mrc"):
    with mrcfile.open(image_path) as mrc_file:
      data = np.array(mrc_file.data)
  elif image_path.endswith(".png"):
    data = np.array(Image.open(image_path))
  else:
    print("File does not end with '.mrc' or other image formats: " + image_path)
    return

  mrc_file_name = image_path.split("/")[-1]

  if len(data.shape) > 2:
    for i, image_data in np.ndenumerate(data):
      cbox_file_name = remove_suffix(mrc_file_name, ".mrc") +  "_slice" + "{:04d}".format(i) + ".box"
      cbox_file_path = predicted_dir_path + cbox_file_name
      expected_cbox_file_path = None if expected_dir_path == None else expected_dir_path + cbox_file_name

      equalized_image = equalize_image(image_data)
      print(green_color, "Annotating", mrc_file_name, "(", i + 1, "/", len(data), ")", reset_color)
      annotate(equalized_image, cbox_file_path, expected_cbox_file_path, output_dir_path, box_size)
  else:
    cbox_file_path = predicted_dir_path + remove_suffix(mrc_file_name, ".mrc") + ".box"
    expected_cbox_file_path = None if expected_dir_path == None else expected_dir_path + remove_suffix(mrc_file_name, ".mrc") + ".coord"
    
    equalized_image = equalize_image(data)
    print(green_color, "Annotating", mrc_file_name, "(1/1)", reset_color)
    annotate(equalized_image, cbox_file_path, expected_cbox_file_path, output_dir_path, box_size)

  return



with mrcfile.open("/home/tl699/cryolo-sphire/input/EMPIAR-10017/Falcon_2012_06_12-14_33_35_0.mrc") as mrc_file:
  data = np.array(mrc_file.data)
equalized_image = equalize_image(data)

annotate(equalized_image, "assets/parsed_output/EMPIAR-10017/Falcon_2012_06_12-14_33_35_0.box", "/home/tl699/cryolo-sphire/output/EMPIAR-10017_expected/CBOX/Falcon_2012_06_12-14_33_35_0.coord", "assets/images_output/EMPIAR-10017_offset", 100)