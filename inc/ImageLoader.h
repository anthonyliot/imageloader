//
//  ImageLoader.h
//
//
//  Created by Anthony Liot on 17/12/12.
//
//

#ifndef __IMAGE_LOADER_H__
#define __IMAGE_LOADER_H__

#include <stdio.h>
#include <stdlib.h>
#include <string>

/*
 */
class ImageLoader {
    
public:

    // constructor
    ImageLoader();
    
    virtual ~ImageLoader();
    
    // load image
    int load(const char *name);

    // swap image
    static int swap(unsigned char *dest, size_t size, int components, int channel_0, int channel_1);

    // flip horizontal
    static void flip_y(unsigned char *dest, int width, int height, int components);

    // Access to the data pointer
    inline const uint8_t *data() const { return _data.data(); }

    // Access to the image width
    inline uint32_t width() const { return _width; }

    // Access to the image height
    inline uint32_t height() const { return _height; }

    // Access to the image number of channels
    inline uint32_t format() const { return _format; }

private:

    std::vector<uint8_t> _data;

    uint32_t _width;
    
    uint32_t _height;

    uint32_t _format;
};

#endif /* __IMAGE_LOADER_H__ */
