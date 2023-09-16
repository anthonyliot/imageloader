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

#include <ImageLoader.h>

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
	printf("Library Image Javascript...\n");
	
	if (argc != 2) {
		printf("main(): number of argument incorrect : %d\n",argc);
		return 1;
	}

    return ImageLoader::load(argv[1],output_width,output_height,output_format) ? EXIT_SUCCESS : EXIT_FAILURE;
}
