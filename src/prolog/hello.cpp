#include <iostream>
#include <SWI-cpp.h>

using namespace std;

PREDICATE(hello, 1) { 
    cout << "Hello " << (char*) A1 << "!" << endl;
    return TRUE;
}

PREDICATE(add, 3) {
    return A3 = (long)A1 + (long)A2;
}

PREDICATE(average, 3) {
    long sum = 0;
    long n = 0;

    PlQuery q("call", PlTermv(A2));
    while (q.next_solution()) {
	sum += (long)A1;
	n++;
    }
    return A3 = (double)sum/(double)n;
}
