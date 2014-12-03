#ifndef _DEFAULT_SOURCE
#define _DEFAULT_SOURCE
#endif

#ifndef _SOCKET_SERVER_H
#define _SOCKET_SERVER_H

#ifdef __cplusplus
extern "C" {
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

// the max connection number of the server
#define MAX_CONNECTION_NUMBER 5

/* Create a server endpoint of a connection. 
 * Returns fd if all OK, fd < 0 on error. 
 */
extern int unix_socket_listen(const char *servername);
extern void unix_socket_close(int fd);
extern int unix_socket_accept(int listenfd, uid_t *uidptr);
extern void client_socket_close(int fd, char* scktmp);
/* Create a client endpoint and connect to a server. 
 *  Returns fd if all OK, < 0 on error.
 */
extern int client_socket_conn(const char *servername, char* scktmp);

#ifdef __cplusplus
}
#endif

#endif
