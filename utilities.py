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