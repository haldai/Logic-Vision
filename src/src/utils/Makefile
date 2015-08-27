#Complier
CC = gcc

#LIBS(Linker Parameter)
#CFLAGS
#Options for release

INCLUDE = -I/usr/include/ncurses -I/usr/include/ -I/usr/include/opencv/ -I/usr/include/opencv2/
CFLAGS = -g -Wall -std=c11 -fPIC `pkg-config --cflags opencv` `pkg-config --cflags Qt5Gui`
LIBS = -lpthread -lncurses -lm -fPIC `pkg-config --libs opencv` `pkg-config --libs Qt5Gui`

all:utils.o

utils.o:
	$(CC) $(CFLAGS) -c utils.c

clean:
	make -C ../ clean
