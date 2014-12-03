# swipl: load_foreign_library(foreign('img_process.so')).

#Source file
SRC = img_process.cpp

#Object file
OBJ = $(SRC:.cpp = .o)

#Compiler
CC = g++

#LIBS
#CFLAGS

CFLAGS = -Wall -shared -fPIC -fno-strict-aliasing -pthread -fPIC -I../../include `pkg-config --cflags opencv`
LIBS = -Wall -shared -fPIC -lm -L../../lib/swipl/x86_64-linux -rdynamic -O2 -pthread -Wl,-rpath=../../lib/swipl/x86_64-linux -lswipl `pkg-config --libs opencv`
all:img_process.so

img_process.so:img_process.o
	$(CC) $(LIBS) img_process.o ../utils/utils.o ../socket/socket_server.o ../socket/message.o -o img_process.so

img_process.o:utils_dir socket_dir
	$(CC) $(CFLAGS) -c img_process.cpp

utils_dir:
	make -C ../utils all

socket_dir:
	make -C ../socket all

clean:
	make -C ../ clean
