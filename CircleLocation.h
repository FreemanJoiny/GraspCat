//
//  CircleLocation.h
//  围住神经猫
//

#import <Foundation/Foundation.h>

@interface CircleLocation : NSObject

@property int row; //存每个点的行
@property int col; //存每个点的列
@property int cost; //存每个点的连接数
@property int path; //存每个点的最短路径数

-(int) calculatePath;
-(int) calculateCost;
-(int) calMaxCost;

-(CircleLocation*) getOppositePoint:(CircleLocation*) pOld;
-(int) getCost:(CircleLocation*) p;

-(int) isInCircle;
-(int) compare:(CircleLocation*) c1;
-(NSMutableArray*) getAllConnectLocation;
-(NSMutableArray*) getIntersectLocation:(CircleLocation*) p;


@end
