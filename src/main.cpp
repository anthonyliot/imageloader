//
//  main.cpp
//
//
//  Created by Anthony Liot on 17/12/12.
//
//

#ifdef USE_EMSCRIPTEN
	#include <emscripten/emscripten.h>
#endif

#include <imageloader.h>

int output_width;
int output_height;
int output_format;

extern "C" {
 	int width() { return output_width; };
 	int height() { return output_height; };
    int format() { return output_format; };
}

/************************/
/*			MAIN		*/
/************************/

int main(int argc, char *argv[])
{
	printf("[INFO] main(): Library Image Loader ...\n");
	
	if (argc != 2) {
		printf("[ERROR] main(): Mumber of argument incorrect : %d\n",argc);
		return 1;
	}

	ImageLoader il;
    if (il.load(argv[1])) {
		printf("[INFO] main(): Image '%s' loaded successfully (%dx%dx%d)\n", argv[1], il.width(), il.height(), il.format());
		return EXIT_SUCCESS;
	}
	
	return EXIT_FAILURE;
}
