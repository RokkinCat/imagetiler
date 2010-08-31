# imagetiler -- A simple tool to tile images.

### Description

imagetiler breaks up images into smaller tiles, suitable for use with Google Maps.

### How to use

#### From the command line

`ruby tile_image.rb -o OUTPUT_DIR -z ZOOM_LEVELS IMAGE_FILE`  

For example

`ruby tile_image.rb -o ./tiles -z 2..4 ./input_files/map.jpg`


#### From ruby

`require 'imagetiler'
t = Tiler.new  
t.make_tiles(image_source, opts)`

`image_source` can be either a filename or an RMagick Image.

You can set options two ways:  
`t.zoom_levels = 2..4`  
or  
`t.get_tiles(image, :zoom_levels => 2..4)`

Setting options in the get_tiles function sets them for that instance of Tiler.


### Methods

`make_tiles(image_source, opts)`  

`calc_native_res_zoom` : Calculates the zoom level closest to native resolution. Returns a float for the zoom -- so, use zoom.ceil if you want the higher zoom, for example



### Output
Tiles in the output folder with format  
`#{output_dir}/#{prefix}_#{zoom_level}_#{tile_col}_#{tile_row}.#{image_format}`


### Options

`zoom_levels` : Zoom level 0 shows the entire image as one 256x256 tile. Subsequent zoom levels double both the horizontal and vertical sides. Default is 0..4
`output_dir` : Defaults to the current directory. Don't include the ending '/'  
`bg_color` : The background fill color, transparent by default.  
`autocreate_dirs` : Whether or not to create the directory if it exists. Default true  
`format` : The format for the output, defaults to 'jpg'. Can be png, gif, etc.
`prefix` : Prefix for the output files. Defaults to 'tile'

### Other things
* Requires rmagick.
* Might not work on Windows as written -- change the '/' for the output to '\\'


### Credits
This tiler is modified Guilhem's tile_image.rb tool, which is part of the ym4r project. The Tiler itself has been re-written, and TileParam is no longer used.  
Thanks to Guilhem for the command-line portions and the sample ruby and rmagick code!


### License
imagetiler uses the MIT License.