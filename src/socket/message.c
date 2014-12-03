#include <string.h>
#include <opencv/cv.h>

#include "message.h"

MyMessage* myCreateMsg(int msg_type) {
    MyMessage* re = (MyMessage *) malloc(sizeof(MyMessage));
    re->msg_type = msg_type;
    return re;
}
