#Source file
SRC = test.c kmeans.c

#Object file
OBJ = $(SRC:.c = .o)

#Output execution file
PROGRAM = test

#Complier
CC = gcc

#LIBS(Linker Parameter)
#CFLAGS
#Options for release

INCLUDE = -I/usr/include/ncurses -I/usr/include/ -I/usr/include/opencv/ -I/usr/include/opencv2/
CFLAGS = -g -Wall -std=c11 -fPIC `pkg-config --cflags opencv`
LIBS = -lpthread -lncurses -lm -fPIC `pkg-config --libs opencv`

all:test sampler_dir utils_dir socket_dir prolog_dir sampler_dir

kmeans:
	$(CC) $(CFLAGS) kmeans.c -o kmeans $(LIBS)

test:test.o sampler_dir utils_dir
	$(CC) $(CFLAGS) test.o ./sampler/subimg.o ./sampler/sampler.o ./sampler/descriptor.o ./sampler/quantize.o ./utils/utils.o -o test $(LIBS)

test.o:
	$(CC) $(CFLAGS) -c -o test.o test.c

sampler_dir:
	-make -C ./sampler all

utils_dir:
	-make -C ./utils all

socket_dir:utils_dir
	-make -C ./socket all

prolog_dir:utils_dir
	-make -C ./prolog all

clean:
	-rm -f *.o ./sampler/*.o ./utils/*.o ./socket/*.o ./prolog/*.o
	-rm -f ./prolog/*.so
	-rm -f ./socket/img_server ./socket/img_client
	-rm -f kmeans test
