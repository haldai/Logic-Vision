/* The authors of this work have released all rights to it and placed it
in the public domain under the Creative Commons CC0 1.0 waiver
(http://creativecommons.org/publicdomain/zero/1.0/).

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Retrieved from: http://en.literateprograms.org/Median_cut_algorithm_(C_Plus_Plus)?oldid=19175
*/

#include <iostream>
#include <cstdlib>
#include <stdio.h>

#include "../sampler/median_cut.h"

int main(int argc, char* argv[]) {
    FILE * raw_in;
    int numPoints = atoi(argv[2]) * atoi(argv[3]);
    Point* points = (Point*)malloc(sizeof(Point) * numPoints);

    raw_in = fopen(argv[1], "rb");
    for(int i = 0; i < numPoints; i++)
    {
        fread(&points[i], 3, 1, raw_in);
    }
    fclose(raw_in);

    std::list<Point> palette =
        medianCut(points, numPoints, atoi(argv[4]));

    std::list<Point>::iterator iter;
    for (iter = palette.begin() ; iter != palette.end(); iter++)
    {
        std::cout << (int)iter->x[0] << " "
                  << (int)iter->x[1] << " "
                  << (int)iter->x[2] << std::endl;
    }

    return 0;
}
