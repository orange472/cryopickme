# CryoPickMe

CRYO-EM particle picking project under Tony and Leo.

- [CryoPickMe](#cryopickme)
  - [Getting Started](#getting-started)
    - [Installing EPicker](#installing-epicker)

## Getting Started
To get started, make sure you have conda installed.

### Installing EPicker

1. Create a conda environment for EPicker
   ```sh
   conda create -n epicker -c conda-forge python=3.6.11 cudatoolkit-dev=11.0
   ```
2. Activate the conda environment
   ```sh
   conda activate epicker
   ```
3. Clone the [EPicker repository](https://github.com/thuem/EPicker)
   ```sh
   git clone https://github.com/thuem/EPicker.git
   ```
4. Install remaining packages
   ```sh
   pip install Cython==0.29.22 numpy==1.19.5 scipy==1.5.2 pycparser cffi dataclasses typing_extensions six cycler certifi pyparsing python_dateutil kiwisolver llvmlite numba==0.48.0 future decorator progress easydict networkx Pillow matplotlib pycocotools opencv_python torch==1.7.1+cu110 -f https://download.pytorch.org/whl/torch_stable.html torchvision==0.8.2+cu110 -f https://download.pytorch.org/whl/torch_stable.html
   ```
5. Navigate to the DCNv2 path inside EPicker
   ```sh
   cd EPicker/lib/models/networks/DCNv2
   ```
6. Run the following commands
   ```sh
   rm -r build
   python setup.py build develop /usr/bin/g++
   ```