#ifndef _DEFAULT_SOURCE
#define _DEFAULT_SOURCE
#endif

#include <stdio.h>
#include <unistd.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <sys/socket.h>
#include <sys/un.h>

#include "../socket/socket_server.h"

/* Create a server endpoint of a connection. 
 * Returns fd if all OK, fd < 0 on error. 
 */
int unix_socket_listen(const char *servername) { 

    int fd;
    struct sockaddr_un serv_un; 
    size_t size;
    
    /* create socket */
    fd = socket(AF_LOCAL, SOCK_STREAM, 0);
    if (fd < 0) {
	perror("socket");
	exit(EXIT_FAILURE);
    }

    unlink(servername); // in case it already exists
    
    memset(&serv_un, 0, sizeof(serv_un)); 
    serv_un.sun_family = AF_LOCAL; 
    strncpy(serv_un.sun_path, servername, sizeof(serv_un.sun_path));
    serv_un.sun_path[sizeof(serv_un.sun_path) - 1] = '\0';
    
    size = (offsetof(struct sockaddr_un, sun_path)
	   + strlen(servername)); 
    /* bind the name to the descriptor */ 
    if (bind(fd, (struct sockaddr *) &serv_un, size) < 0) { 
	perror("ERROR server binding");
	close(fd);
	unlink(servername);
	exit(EXIT_FAILURE);
    } else {
	if (listen(fd, MAX_CONNECTION_NUMBER) < 0) {
	    perror("ERROR connection out of number");
	    close(fd);
	    unlink(servername);
	    exit(EXIT_FAILURE);
	} else {
	    return fd;
	}
    }
}

void unix_socket_close(int fd) {
    close(fd);
}

int unix_socket_accept(int listenfd, uid_t *uidptr) { 
    int clifd, clilen;
    struct sockaddr_un cli_un;
    struct stat statbuf;
    clilen = sizeof(cli_un);
    
    clifd = accept(listenfd, (struct sockaddr *) &cli_un, (socklen_t *) &clilen);
    if (clifd < 0) {
	perror("ERROR client accept");
	exit(EXIT_FAILURE);
    }

    /* obtain the client's uid from its calling address */ 
    clilen -= offsetof(struct sockaddr_un, sun_path);  /* len of pathname */
    cli_un.sun_path[clilen] = '\0'; /* null terminate */ 

    if (stat(cli_un.sun_path, &statbuf) < 0) {
	perror("ERROR client socket path");
	printf("%s\n", cli_un.sun_path);
	unix_socket_close(clifd);
	exit(EXIT_FAILURE);
    } else {
	if (S_ISSOCK(statbuf.st_mode)) { 
	    if (uidptr != NULL) 
		*uidptr = statbuf.st_uid;    /* return uid of caller */ 
	    unlink(cli_un.sun_path);       /* we're done with pathname now */ 
	    return clifd;		 
	} else {
	    perror("client is not a socket");
	    unix_socket_close(clifd);
	    exit(EXIT_FAILURE);
	}
    }
}

void client_socket_close(int fd, char* scktmp) {
    close(fd);
    unlink(scktmp);
}

int client_socket_conn(const char *servername, char* scktmp) { 
    int fd; 
    /* create a UNIX domain stream socket */ 
    if ((fd = socket(AF_LOCAL, SOCK_STREAM, 0)) < 0) {
	perror("ERROR client socket");
	exit(EXIT_FAILURE);
    }

    int clilen;
    struct sockaddr_un cli_un;

    /* fill socket address structure with our address */
    memset(&cli_un, 0, sizeof(cli_un)); 
    cli_un.sun_family = AF_LOCAL; 
    
    sprintf(cli_un.sun_path, scktmp);
    
    clilen = offsetof(struct sockaddr_un, sun_path) + strlen(cli_un.sun_path);
    unlink(cli_un.sun_path); // in case it already exists
    if (bind(fd, (struct sockaddr *) &cli_un, clilen) < 0) { 
	perror("ERROR client socket binding");
	exit(EXIT_FAILURE);
    } else {
	/* fill socket address structure with server's address */
	memset(&cli_un, 0, sizeof(cli_un)); 
	cli_un.sun_family = AF_LOCAL; 
	strcpy(cli_un.sun_path, servername); 
	clilen = offsetof(struct sockaddr_un, sun_path) + strlen(servername); 
	if (connect(fd, (struct sockaddr *) &cli_un, clilen) < 0) {
	    perror("ERROR client socket connecting to server");
	    client_socket_close(fd, scktmp);
	    exit(EXIT_FAILURE);
	} else {
	    return fd;
	}
    }
}
