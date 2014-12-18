#Complier
CC = gcc

#LIBS(Linker Parameter)
#CFLAGS
#Options for release

INCLUDE = -I/usr/include/ncurses -I/usr/include/ -I/usr/include/opencv/ -I/usr/include/opencv2/
CFLAGS = -g -Wall -std=c11 -fPIC `pkg-config --cflags opencv`
LIBS = -lpthread -lncurses -lm -fPIC `pkg-config --libs opencv`

all:subimg.o quantize.o sampler.o descriptor.o

subimg.o:
	$(CC) $(CFLAGS) -c subimg.c

quantize.o:
	$(CC) $(CFLAGS) -c quantize.c

sampler.o:descriptor.o
	$(CC) $(CFLAGS) -c sampler.c

descriptor.o:subimg.o
	$(CC) $(CFLAGS) -c descriptor.c

clean:
	make -C ../ clean
