#import "SKShapeNode+Area.h"

static void extractPointApplier(void* info, const CGPathElement* element) {
    [((__bridge NSMutableArray*) info) addObject:[NSValue valueWithCGPoint:*element->points]];
}

@implementation SKShapeNode (Area)

-(float) area {
    NSMutableArray* pathPoints = [NSMutableArray array];
    CGPathApply(self.path, (__bridge void *)(pathPoints), extractPointApplier);

    float area = 0;
    NSUInteger j = [pathPoints count]-1;
    for (NSUInteger i = 0; i < [pathPoints count]; i++) {
        CGPoint pointJ = [[pathPoints objectAtIndex:j] CGPointValue];
        CGPoint pointI = [[pathPoints objectAtIndex:i] CGPointValue];
        area += (pointJ.x+pointI.x) * (pointJ.y-pointI.y);
        j = i;
    }
    return abs(area/2);
}

@end
