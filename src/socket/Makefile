#Output execution file
PROGRAM = img_server img_client

#Complier
CC = gcc

#LIBS(Linker Parameter)
#CFLAGS
#Options for release

INCLUDE = -I/usr/include/ncurses -I/usr/include/ -I/usr/include/opencv/ -I/usr/include/opencv2/
CFLAGS = -g -Wall -std=c11 -fPIC `pkg-config --cflags opencv`
LIBS = -lpthread -lncurses -lm -fPIC `pkg-config --libs opencv`

all:img_server socket_server.o img_server.o message.o img_client

img_server:socket_server.o img_server.o message.o image_process.o sampler_dir utils_dir
	$(CC) $(LIBS) socket_server.o img_server.o message.o image_process.o ../sampler/quantify.o ../sampler/sampler.o ../sampler/descriptor.o ../sampler/subimg.o ../utils/utils.o -o img_server

utils_dir:
	-make -C ../utils all

sampler_dir:
	-make -C ../sampler all

image_process.o:utils_dir
	$(CC) $(CFLAGS) -c image_process.c

img_server.o:utils_dir
	$(CC) $(CFLAGS) -c img_server.c

socket_server.o:
	$(CC) $(CFLAGS) -c socket_server.c

message.o:
	$(CC) $(CFLAGS) -c message.c

img_client:img_client.o socket_server.o message.o
	$(CC) $(LIBS) img_client.o socket_server.o message.o -o img_client

img_client.o:
	$(CC) $(CFLAGS) -c img_client.c

clean:
	-make -C ../ clean
