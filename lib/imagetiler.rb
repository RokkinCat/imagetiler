#  Copyright (c) 2010 Anna <tanna22@gmail.com>
#  Copyright (c) 2006 Guilhem Vellut <guilhem.vellut+ym4r@gmail.com>
#  
#  Permission is hereby granted, free of charge, to any person obtaining a copy of this software
#  and associated documentation files (the "Software"), to deal in the Software without
#  restriction, including without limitation the rights to use, copy, modify, merge, publish,
#  distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
#  Software is furnished to do so, subject to the following conditions:
#  
#  The above copyright notice and this permission notice shall be included in all copies or
#  substantial portions of the Software.
#  
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
#  BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
#  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING 
#  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

require 'rubygems'
require 'RMagick'
require 'optparse'
require 'ostruct'

class Tiler

    TILE_SIZE = 256

    attr_accessor :zoom_levels, :bg_color, :format, :prefix

    def initialize()
        @zoom_levels = 0..4
        @bg_color = Magick::Pixel.new(255,255,255,Magick::TransparentOpacity)
        @format = "png"
        @prefix = "tile"
    end

    # image_source is an RMagick Image
    def make_tiles(image_source, opts={})

        # initializing and setting options and stuff
        image = get_image(image_source)
        opts.each_pair do |key,value|
            instance_variable_set "@#{key}", value
        end

        # pad image with background color so image is square
        image_sq = pad_image(image)
        image_length = image_sq.columns

        # the actual tiling part!
        zoom_levels.each do |zoom|
            # get the number of tiles in each column and row
            factor = 2 ** zoom

            # get length of tiles for current zoom
            tile_length = image_length / factor

            0.upto(factor-1) do |col|
                0.upto(factor-1) do |row|

                    # cut tile
                    # Image.crop(x,y,width,height,toss offset information)
                    tile = image_sq.crop(col*tile_length, row*tile_length, tile_length, tile_length, true)
                    tile.resize!(TILE_SIZE,TILE_SIZE)

                    # output tile
                    yield({:filename => "#{@prefix}_#{zoom}_#{col}_#{row}.#{@format}", :file => tile})
                end
            end
        end
    end

    # Calculates the zoom level closest to native resolution.
    # Returns a float for the zoom -- so, use zoom.ceil if you
    # want the higher zoom, for example
    def calc_native_res_zoom(image_source)
        image = get_image(image_source)
        side_length = calc_side_length(image)
        zoom = log2(side_length)-log2(TILE_SIZE)
        zoom = 0 if zoom < 0
        zoom
    end

    # pad image to the lower right with bg_color so that the 
    # image is square and that the max number of pixels
    # is evenly divisible by the max number of tiles per side
    def pad_image(image)
        dim = calc_side_length(image)

        image.background_color = @bg_color

        image.extent(dim, dim)
    end

    def get_image(image_source)
        case image_source
        when Magick::Image
            image = image_source
        else
            image = Magick::ImageList::new(image_source)
        end
        return image
    end

    def calc_side_length(image)
        long_side = [image.columns, image.rows].max
        max_zoom = @zoom_levels.max
        ceil = (long_side.to_f()/2**max_zoom).ceil
        side_length = ceil*2**max_zoom
    end

    def log2(x)
        Math.log(x)/Math.log(2)
    end
end
