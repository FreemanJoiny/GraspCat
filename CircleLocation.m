//
//  CircleLocation.m
//  围住神经猫
//

#import "CircleLocation.h"

extern CircleLocation *allCircle[9][9];
extern int map[9][9];
extern int hasCircle;

@implementation CircleLocation

-(int)compare:(CircleLocation *)c1
{
    if (self.path >= 0 && c1.path >= 0) {
        if (self.path < c1.path) {
            return 1;
        }
    }
    else if (hasCircle == 1) {
        if (self.cost > c1.cost ) {
            return 1;
        }
        else
            return 0;
    }
    else {
        int m1 = - self.path;
        int m2 = - c1.path;
        if (m1 < m2 ) {
            return 1;
        }
        else
            return 0;
    }
    return 0;
}

-(BOOL) isBoundary
{
    if (self.row == 0 || self.row == 8 ||
        self.col == 0 || self.col == 8) {
        return YES;
    }
    else {
        return NO;
    }
}

-(NSMutableArray *)getIntersectLocation:(CircleLocation *)p
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    NSArray *selfConnects = [self getAllConnectLocation];
    NSArray *pConnects = [p getAllConnectLocation];

    for (CircleLocation* obj1 in selfConnects) {
        if (obj1.cost == 100) {//它是墙
            continue;
        }
        for (CircleLocation *obj2 in pConnects) {
            if (obj2.cost == 100) {//它是墙
                continue;
            }
            if (obj1 == obj2) {
                [arr addObject:obj2];
            }
        }
    }
    return arr;
}

-(int) isInArray:(NSArray*)arr
{
    for (CircleLocation* obj in arr) {
        if (obj == self) {
            return 1;
        }
    }
    return 0;
}

-(int)getCost:(CircleLocation *)p
{
    NSArray *allConnectLocation = [self getAllConnectLocation];
    int wallNum = 0;
    for (CircleLocation* obj in allConnectLocation) {
        if (obj.cost == 100) {//它是墙
            wallNum++;
        }
    }

    if (wallNum == 6) {
        return 0;
    }
    else {
        NSArray *allIntersects = [self getIntersectLocation:p];
        int sum = 0;
        for (CircleLocation* obj in allConnectLocation) {
            if (obj.path == 100) {//它是墙
                continue;
            }
            else {
                int res = [obj isInArray:allIntersects];
                if (res == 0) {
                    sum += obj.cost;
                }
            }
        }
        return sum;
    }
}
-(int) calMaxCost;
{
    //遍历它周围的点，把他们的cost累加起来.
    NSArray *allConnectLocation = [self getAllConnectLocation];
    int wallNum = 0;
    for (CircleLocation* obj in allConnectLocation) {
        if (obj.cost == 100) {//它是墙
            wallNum++;
        }
    }
    
    if (wallNum == 6) {
        return 0;
    }
    else {
        int sum = 0;
        for (CircleLocation* obj in allConnectLocation) {
            if (obj.path == 100) {//它是墙
                continue;
            }
            else {
                sum += obj.cost;
                sum += [obj getCost:self];
            }
        }
        return sum;
    }
}

-(int)isInCircle
{
    //遍历这周围的点，看看他们是否是墙或者是墙内的点（它的值是负数，但大于－100.

    NSArray *allConnectLocation = [self getAllConnectLocation];
    int num = 0;
    for (CircleLocation* obj in allConnectLocation) {
        if (obj.path > 100 ||//它是墙内的点
            (obj.path > -100 &&
             obj.path < 0) ||
            obj.path == 100) {//它是墙
            num++;
        }
    }
    
    if (num == 6) {
        return 1;
    }
    else {
        return 0;
    }
}

-(int)calculateCost
{
    int i = self.row;
    int j = self.col;
    if (map[i][j] == 1) {
        self.cost = 100;
        return self.cost;
    }
    if ([self isBoundary]) {
        self.cost = 0;
        return self.cost;
    }
    NSArray *allConnectLocation = [self getAllConnectLocation];
    int number = 0;
    for (CircleLocation* obj in allConnectLocation) {
        if (map[obj.row][obj.col] == 0) {
            number++;
        }
    }
    self.cost = number;
    return self.cost;
}

-(int)calculatePath
{
    int i = self.row;
    int j = self.col;
    if (map[i][j] == 1) {
        self.path = 100;
        return self.path;
    }
    if ([self isBoundary]) {
        self.path = 0;
        return self.path;
    }
    NSArray *allConnectLocation = [self getAllConnectLocation];
    int min = 100;
    for (CircleLocation* obj in allConnectLocation) {
        if (obj.path > -100) {
            int tmp = obj.path;
            if (obj.path < 0) {
                tmp = -tmp;
            }
            if (min > tmp) {
                min = tmp;
            }
        }
    }
    if (min < 100) {
        self.path = min + 1;
    }
    else {
        self.path += 1;
    }
    return self.path;
}

-(CircleLocation *)getOppositePoint:(CircleLocation *)pOld
{
    NSArray *allConnectLocation = [pOld getAllConnectLocation];
    CircleLocation *p = nil;
    int i = 0;
    for (i = 0; i < 6; i++) {
        p = (CircleLocation*)[allConnectLocation objectAtIndex:i];
        if (p == self) {
            break;
        }
    }
    int j = i;
    if (i+3 >= 6) {
        for (int k = 0; k < 3; k++) {
            j++;
            if ( j > 5) {
                j = 0;
            }
        }
    }
    else {
        j = i + 3;
    }
    return [allConnectLocation objectAtIndex:j];
}




-(NSMutableArray*) getAllConnectLocation
{
    NSMutableArray *arr = [[NSMutableArray alloc]initWithCapacity:6];
    [arr insertObject:[self getLeftUp] atIndex:0];
    [arr insertObject:[self getLeft] atIndex:1];
    [arr insertObject:[self getLeftDown] atIndex:2];
    [arr insertObject:[self getRightDown] atIndex:3];
    [arr insertObject:[self getRight] atIndex:4];
    [arr insertObject:[self getRightUp] atIndex:5];
    
    return arr;
}

-(CircleLocation*) getLeft
{
    CircleLocation* newp = NULL;
    if (self.col > 0) {
        newp = allCircle[self.row][self.col-1];
    }
    return newp;
}

-(CircleLocation*) getRight
{
    CircleLocation* newp = NULL;
    if (self.col < 8) {
        newp = allCircle[self.row][self.col+1];
    }
    return newp;
}
-(CircleLocation*)  getLeftDown
{
    CircleLocation* newp = NULL;
    if (self.row < 8) {
        CircleLocation* p = allCircle[self.row+1][self.col];
        if (self.row % 2 == 0) {
            if (self.col == 0) {
                newp = NULL;
            }
            else {
                newp = allCircle[self.row+1][self.col-1];
            }
        }
        else {
            newp = p;
        }
    }
    return newp;
}
-(CircleLocation*) getRightDown
{
    CircleLocation* newp = NULL;
    if (self.row < 8) {
        CircleLocation* p = allCircle[self.row+1][self.col];
        if (self.row % 2 == 0) {
            newp = p;
        }
        else {
            if (self.col == 8) {
                newp = NULL;
            }
            else {
                newp = allCircle[self.row+1][self.col+1];
            }
        }
    }
    return newp;
}
-(CircleLocation*)  getRightUp
{
    CircleLocation* newp = NULL;
    if (self.row > 0) {
        CircleLocation* p = allCircle[self.row-1][self.col];
        if (self.row % 2 == 0) {
            newp = p;
        }
        else {
            if (self.col == 8) {
                newp = NULL;
            }
            else {
                newp = allCircle[self.row-1][self.col+1];
            }
        }
    }
    
    return newp;
}
-(CircleLocation*)  getLeftUp
{
    CircleLocation* newp = NULL;
    if (self.row > 0) {
        CircleLocation* p = allCircle[self.row-1][self.col];
        if (self.row % 2 == 0) {
            if (self.col == 0) {
                newp = NULL;
            }
            else {
                newp = allCircle[self.row-1][self.col-1];
            }
        }
        else {
            newp = p;
        }
    }

    return newp;
}
@end
