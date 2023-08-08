def box_file_edit_width_height(file_path, width: str, height: str):
  new_lines: list[str] = []

  # Edit lines and store in array
  with open(file_path, 'r') as file:
    for line in file.readlines():
      words = line.split()
      if len(words) <= 1:
        new_lines.append(line)
      else:
        new_lines.append(" ".join([words[0], words[1], width, height]) + "\n")

  # Write array to file 
  with open(file_path, 'w') as file:
    file.writelines(new_lines)