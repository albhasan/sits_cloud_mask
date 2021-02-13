# sits_cloud_mask

Use CBERS4 images to test the cloud mask algoritm implemented in sits. This
method is described in:

BDC TRAC
http://brazildatacube.dpi.inpe.br/trac/ticket/136

Cloud/shadow detection based on spectral indices for multi/hyperspectraloptical
remote sensing imagery
https://sci-hub.do/https://doi.org/10.1016/j.isprsjprs.2018.07.006

Test image:
http://www.dpi.inpe.br/catalog/tmp/CBERS4A/2020_10/CBERS_4A_WFI_RAW_2020_10_20.13_34_30_ETC2/205_116_0/4_BC_UTM_WGS84/

Suffixes of Surface Reflectance files:
- BAND13_GRID_SURFACE.tif (blue)
- BAND14_GRID_SURFACE.tif (green)
- BAND15_GRID_SURFACE.tif (red)
- BAND16_GRID_SURFACE.tif (nir)

The mask has the suffix:
CMASK_GRID_SURFACE.tif
