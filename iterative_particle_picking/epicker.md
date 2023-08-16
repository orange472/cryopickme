# EPicker

Guide to installing EPicker for REPIC.

- [EPicker](#epicker)
  - [Getting Started](#getting-started)
    - [Installing EPicker](#installing-epicker)
  - [Troubleshooting](#troubleshooting)
  - [Credits](#credits)

## Getting Started
* Before getting started, make sure you have conda installed. 
* EPicker requires a NVIDIA GPU and specified versions of CUDA library installed, currently supporting CUDA 9.0, 10.1, 10.2 and 11.0.

---

### Installing EPicker

1. Clone the [EPickerForREPIC](https://github.com/orange472/EPickerForREPIC) repository
   ```sh
   git clone https://github.com/orange472/EPickerForREPIC.git EPicker
   ```
   **Note**: This is NOT the original EPicker repository.

2. Create a conda environment for EPicker
   ```sh
   conda create -n epicker -c conda-forge python=3.6.11 cudatoolkit-dev=11.0
   ```
   **Note**: Please specify a different version number for ```cudatoolkit-dev``` if you want to install a different CUDA version.

3. Activate the conda environment
   ```sh
   conda activate epicker
   ```
4. Install the remaining packages
   ```sh
   pip install Cython==0.29.22 numpy==1.19.5 scipy==1.5.2 pycparser cffi dataclasses typing_extensions six cycler certifi pyparsing python_dateutil kiwisolver llvmlite numba==0.48.0 future decorator progress easydict networkx Pillow matplotlib pycocotools opencv_python torch==1.7.1+cu110 -f https://download.pytorch.org/whl/torch_stable.html torchvision==0.8.2+cu110 -f https://download.pytorch.org/whl/torch_stable.html
   ```
   **Note**: Make sure that ```torch``` and ```torchvision``` are supported by the installed CUDA version.

5. Navigate to the DCNv2 path inside EPicker
   ```sh
   cd EPicker/lib/models/networks/DCNv2
   ```
6. Run the following commands:
   ```sh
   rm -r build
   ```
   ```sh
   python setup.py build develop /usr/bin/g++
   ```
   **Troublshooting**: If the second command fails, make sure that your actual GPU driver is up to date.

---

## Troubleshooting

If a `.sh` file is unable to be run, please run the following command, replacing `path/to/file.sh` with the path to your file.
  
```sh
chmod u+x path/to/script.sh
```

---

## Credits

EPicker is developed by Xueming Li Lab. Please visit the [EPicker website](http://thuem.net/software/epicker/overview.html) for more information.
