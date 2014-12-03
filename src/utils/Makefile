#Complier
CC = gcc

#LIBS(Linker Parameter)
#CFLAGS
#Options for release

INCLUDE = -I/usr/include/ncurses -I/usr/include/ -I/usr/include/opencv/ -I/usr/include/opencv2/
CFLAGS = -g -Wall -std=c11 -fPIC `pkg-config --cflags opencv`
LIBS = -lpthread -lncurses -lm -fPIC `pkg-config --libs opencv`

all:utils.o

utils.o:
	$(CC) $(CFLAGS) -c utils.c

clean:
	make -C ../ clean
