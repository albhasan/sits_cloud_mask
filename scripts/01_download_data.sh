#!/bin/bash
# Download test images

path="http://www.dpi.inpe.br/catalog/tmp/CBERS4A/2020_10/CBERS_4A_WFI_RAW_2020_10_20.13_34_30_ETC2/205_116_0/4_BC_UTM_WGS84/"
out_dir="/home/alber.ipia/Documents/sits_cloud_mask/data/raster/CBERS4A/2020_10/CBERS_4A_WFI_RAW_2020_10_20.13_34_30_ETC2/205_116_0/4_BC_UTM_WGS84"

wget "$path/CBERS_4A_WFI_20201020_205_116_L4_BAND13_GRID_SURFACE.tif" -P $out_dir
wget "$path/CBERS_4A_WFI_20201020_205_116_L4_BAND14_GRID_SURFACE.tif" -P $out_dir
wget "$path/CBERS_4A_WFI_20201020_205_116_L4_BAND15_GRID_SURFACE.tif" -P $out_dir
wget "$path/CBERS_4A_WFI_20201020_205_116_L4_BAND16_GRID_SURFACE.tif" -P $out_dir
wget "$path/CBERS_4A_WFI_20201020_205_116_L4_CMASK_GRID_SURFACE.tif"  -P $out_dir

exit 1