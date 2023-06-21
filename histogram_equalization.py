import numpy as np
import cv2

def equalize_image(image_data: np.ndarray):
  '''
  Applys OpenCV's histogram equalization to a grayscale image.

  Params:
    `image_data`: Image data to be equalized, represented as a numpy array of floats.
  
  Returns: The equalized image data.
  '''

  # Convert to uint8 data type
  normalized_image = (image_data - np.min(image_data)) / (np.max(image_data) - np.min(image_data))
  casted_image = (normalized_image * 255).astype(np.uint8)

  # Apply histogram equalization and convert back to original data type (float)
  equalized_image = cv2.equalizeHist(casted_image)
  equalized_image = equalized_image.astype(np.float32) / 255.0

  return equalized_image