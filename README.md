# tigerMeta - Metadata for TIGER spatial data

Downloads and parses metadata from the TIGER spatial data
provided by the US Census Bureau. In addition to the metadata
given directly in the dbf files, it also computes the centroid
of the regions (and can be easily changed to compute other
characteristics). Records for some of the most commonly used
region types are included directly in the repository for ease
of use. The code runs fairly quickly, but the Census FTP site
can be very slow at times.

I created this code because I often deal with data provided
by the US government that is tied to elements such as census
blocks, block groups, or tracts. While the Census Bureau does
a great job of providing shapefiles for describing the
polygons of these regions, I often find that I only need
basic metadata for these regions rather than the entire polygons.
Very granular data, such as the block-level information from
the LEED dataset is often best visualized as spatial points
rather than polygons when looking at regions and larger than
a single neighborhood.
