echo '#include <SDL.h>' > stub.c
gcc -I /d/DevKit/ufo-master/SDL-1.2.15/include/ -E stub.c | grep -v '^#' | grep -v '^$' > ffi_SDL.h
# gcc -I /usr/include/SDL -E stub.c | grep -v '^#' | grep -v '^$' > ffi_SDL.h
# gcc -I /d/DevKit/ufo-master/SDL-widgets-2.0/include/ -E stub.c | grep -v '^#' | grep -v '^$' > ffi_iup.h