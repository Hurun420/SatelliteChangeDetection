# SatelliteChangeDetection
Computer Vision Challenge project for satellite image change detection.

## Overview
This project is a MATLAB-based GUI application to detect and visualize large-scale changes between satellite images taken at different times.  

The app enables users to:
- Import time-stamped satellite images
- Automatically align images (rotation, translation, brightness)
- Select and compare earliest vs latest images
- Visualize differences using multiple modes:
  - Slider Comparison
  - Time-lapse Animation
  - Absolute Change Detection
  - Speed Analysis
  - Land Use Classification
The project meets the SoSe 2025 Computer Vision Challenge rerequirements and is compatible with unknown satellite image datasets in .jpg/.png format.

 ## Requirements
 - MATLAB 2024a or compatible version
 #### Required Toolboxes:
  - Image Processing Toolbox
  - Computer Vision Toolbox
 
 ## Project Structure
 SatelliteChangeDetection/
 ```
.
├── detection/
│   ├── classification_change_landuse.m
│   ├── classification_landuse.m
│   ├── compute_landuse.m
│   ├── compute_absolute.m
│   ├── compute_speed.m
│   └── detect_changes.m
├── gui/
│   ├── app1.mlapp
│   ├── SpeedColor.png
├── preprocessing/
│   └── register_images.m
├── testImage/
│   ├── Brazilian Rainforest
│   ├── Columbia Glacier
│   ├── Dubai
│   ├── Frauenkirche
│   ├── Kuwait
│   └── Wiesn
├── main.m
└── README.md
```

 
 ## Preprocessing Module
 register_images.m
 This function automatically aligns all images in a selected folder to the first image using a SURF feature-based approach and similarity transformation. It robustly handles:
 - Rotation and translation differences
 - Brightness and exposure differences
 - Poor match filtering (scale/rcond rejection)
 - Optional max trial customization for RANSAC
 ### Inputs:
 - folderPath: string, path to the folder containing the images
 - imageList: Cell array of filenames (e.g., {'2020_01.jpg', '2023_04.jpg'})
 ### Outputs:
 - alignedImagesGray: cell array of aligned grayscale images
 - alignedImagesRGB:  cell array of aligned RGB images
 - transformParams:   cell array of geometric transform objects
 - successIndices:    indices of imageList that were successfully aligned

 ## GUI Module
 This is the main graphical user interface built with MATLAB App Designer. It provides:
 - A folder browser to select satellite image folders
 - An "Analyze" button to run registration and compute change maps
 - A "View" button group to explore results with:
   - View:
     Displays the sequence of selected earliest and latest images, with support for grayscale or RGB mode.
   - Slider:
     Interactive slider to blend between earliest and latest images for direct visual comparison.
   - Time-lapse:
     Plays a frame-by-frame animation showing gradual changes over time.
   - Absolute:
     Detects and overlays pixel-wise absolute differences between consecutive images.
   - Speed:
     Analyzes and visualizes how quickly regions change over time.
   - Land Use:
     Classifies detected changes into simplified land use categories based on tiled analysis.

 ## How to Run
 1. Launch the App
    Run main.m to open the GUI.
 2. Load Images
    Use the Browse button to select a folder containing .jpg/.png images named like YYYY_MM.jpg. For example, Testimages-Frauenkirche.
 3. Analyze
    Click the Analyze button. Images will be aligned using the preprocessing module.
 4. Visualize
    After analysis, you can explore different visualization modes (View, Slider, Time-lapse, Absolute, Speed, Land Use).

 ## Notes
 - Only official MathWorks toolboxes are used.
 - Tested for datasets with varying lighting, scale, and viewpoint.
 - The app can be tested using provided data or new folders following naming conventions (e.g., 2008_04.jpg, 2018.jpg). 
 
 
