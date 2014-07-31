#import "SKShapeNode+Cuttable.h"

static void extractPointApplier(void* info, const CGPathElement* element) {
    [((__bridge NSMutableArray*) info) addObject:[NSValue valueWithCGPoint:*element->points]];
}

@implementation SKShapeNode (Cuttable)

-(NSArray*)cutWithLine:(AGKLine)cutLine {
    
    // Get the points from the path
    NSMutableArray* pathPoints = [NSMutableArray array];
    CGPathApply(self.path, (__bridge void *)(pathPoints), extractPointApplier);
    
    // Update the path points with the nodes position and rotation
    NSMutableArray* normalizedPathPoints = [self translateAndRotatePath:pathPoints];
    
    // Determine if and where the intersection occurs
    NSUInteger cutIndexOne = 0;
    NSUInteger cutIndexTwo = 0;
    CGPoint cutIntersectionOne;
    CGPoint cutIntersectionTwo;
    for (NSUInteger i = 1; i < [normalizedPathPoints count]; i++) {
        AGKLine shapeSegment = AGKLineMake([[normalizedPathPoints objectAtIndex:(i-1)] CGPointValue],
                                           [[normalizedPathPoints objectAtIndex:i] CGPointValue]);
        CGPoint intersectionPoint;
        if (AGKLineIntersection(cutLine, shapeSegment, &intersectionPoint)) {
            if (cutIndexOne == 0) {
                cutIntersectionOne = intersectionPoint;
                cutIndexOne = i;
            } else {
                cutIntersectionTwo = intersectionPoint;
                cutIndexTwo = i;
            }
        }
    }
    
    // Create two new SKShapeNodes if there is a split
    if (cutIndexTwo != 0) {
        
        // Shape one
        CGMutablePathRef firstShapePath = CGPathCreateMutable();
        CGPoint firstPoint = [[normalizedPathPoints objectAtIndex:0] CGPointValue];
        CGPathMoveToPoint(firstShapePath, NULL, firstPoint.x, firstPoint.y);
        for (NSUInteger i = 1; i < cutIndexOne; i++) {
            CGPoint nextPoint = [[normalizedPathPoints objectAtIndex:i] CGPointValue];
            CGPathAddLineToPoint(firstShapePath, NULL,nextPoint.x, nextPoint.y);
        }
        CGPathAddLineToPoint(firstShapePath, NULL, cutIntersectionOne.x, cutIntersectionOne.y);
        CGPathAddLineToPoint(firstShapePath, NULL, cutIntersectionTwo.x, cutIntersectionTwo.y);
        for (NSUInteger i = cutIndexTwo; i < [normalizedPathPoints count]; i++) {
            CGPoint nextPoint = [[normalizedPathPoints objectAtIndex:i] CGPointValue];
            CGPathAddLineToPoint(firstShapePath, NULL,nextPoint.x, nextPoint.y);
        }
        
        SKShapeNode* nextShape = [[SKShapeNode alloc] init];
        nextShape.path = firstShapePath;
        nextShape.strokeColor = self.strokeColor;
        nextShape.fillColor = self.fillColor;
        if (self.physicsBody != nil) {
            nextShape.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:firstShapePath];
            nextShape.physicsBody.velocity = self.physicsBody.velocity;
        }
        
        // Shape two
        CGMutablePathRef secondShapePath = CGPathCreateMutable();
        CGPathMoveToPoint(secondShapePath, NULL, cutIntersectionOne.x, cutIntersectionOne.y);
        for (NSUInteger i = cutIndexOne; i < cutIndexTwo; i++) {
            CGPoint nextPoint = [[normalizedPathPoints objectAtIndex:i] CGPointValue];
            CGPathAddLineToPoint(secondShapePath, NULL,nextPoint.x, nextPoint.y);
        }
        CGPathAddLineToPoint(secondShapePath, NULL, cutIntersectionTwo.x, cutIntersectionTwo.y);
        CGPathAddLineToPoint(secondShapePath, NULL, cutIntersectionOne.x, cutIntersectionOne.y);
        
        SKShapeNode* shapeTwo = [[SKShapeNode alloc] init];
        shapeTwo.path = secondShapePath;
        shapeTwo.strokeColor = self.strokeColor;
        shapeTwo.fillColor = self.fillColor;
        
        if (self.physicsBody != nil) {
            shapeTwo.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:secondShapePath];
            shapeTwo.physicsBody.velocity = self.physicsBody.velocity;
        }
        
        return [NSArray arrayWithObjects:nextShape, shapeTwo, nil];
    }
    return [NSArray array];
}

#pragma mark Private

-(NSMutableArray*)translateAndRotatePath:(NSMutableArray*) path {
    NSMutableArray* translated = [NSMutableArray arrayWithCapacity:[path count]];
    for (NSValue* NSValueWrappedPoint in path) {
        CGPoint point = [NSValueWrappedPoint CGPointValue];
        point = CGPointAdd_AGK(self.position, point);
        point = CGPointRotateAroundOrigin_AGK(point, self.zRotation, self.position);
        [translated addObject:[NSValue valueWithCGPoint:point]];
    }
    return translated;
}

@end
