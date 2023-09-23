//
//  main.cpp
//
//
//  Created by Anthony Liot on 17/12/12.
//
//

#include <imageloader.h>
#include <imageversion.h>

#ifdef USE_EMSCRIPTEN
#include <emscripten/bind.h>
#include <emscripten/val.h>

using namespace emscripten;

EMSCRIPTEN_BINDINGS()
{
    class_<ImageLoaderVersion>("ImgLoaderVersion")
        .class_function("version", &ImageLoaderVersion::version)
        .class_function("version_long", &ImageLoaderVersion::version_long)
        .class_function("version_hex", &ImageLoaderVersion::version_hex)
        .class_function("version_major", &ImageLoaderVersion::version_major)
        .class_function("version_minor", &ImageLoaderVersion::version_minor)
        .class_function("version_sha", &ImageLoaderVersion::version_sha)
        .class_function("version_name", &ImageLoaderVersion::version_name)
        .class_function("version_date", &ImageLoaderVersion::version_date);

    class_<ImageLoader>("ImgLoader")
        .constructor<>()                                                      
        .function("load", &ImageLoader::load, allow_raw_pointers())                     
        .function("width", &ImageLoader::width)
        .function("height", &ImageLoader::height)
        .function("format", &ImageLoader::format)	
        .function("size", &ImageLoader::size)
        .function("data", optional_override([](ImageLoader& self) {
            const uint8_t* values = self.data();
            emscripten::val view { emscripten::typed_memory_view(self.size(), values) };
            auto result = emscripten::val::global("Uint8Array").new_(self.size());
            result.call<void>("set", view);
            return result;
        }));
}
#endif



/************************/
/*			MAIN		*/
/************************/

int main(int argc, char *argv[])
{
#ifdef USE_EMSCRIPTEN
    return EXIT_SUCCESS;
#else
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
#endif
}
