#import "SKShapeNode+Cuttable.h"

// Shapes smaller than the SMALL_SHAPE_SIZE will not be created.
// Note*: If a new node is very small and gets added to the scene with a physics body and a
// mass less than 0, then an assertion fails and the application crashes. This define serves
// as a dual prupose to allow small shapes to never be created and prevents these crashes to
// occur. AN alternative implementation would be to return an empty array.
#define SMALL_SHAPE_SIZE 4.0f

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
        
        // Set as null if the size is to small
        if ([nextShape area] <= SMALL_SHAPE_SIZE) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
            nextShape = [NSNull null];
#pragma clang diagnostic pop
        
        } else if (self.physicsBody != nil) {
            nextShape.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:firstShapePath];
            nextShape.physicsBody.velocity = self.physicsBody.velocity;
            //nextShape.physicsBody.angularVelocity = self.physicsBody.angularVelocity;
            // really becomes an angular velocity around the center point
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

        // Set as null if the size is to small
        if ([shapeTwo area] <= SMALL_SHAPE_SIZE) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
            shapeTwo = [NSNull null];
#pragma clang diagnostic pop
            
        } else if (self.physicsBody != nil) {
            shapeTwo.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:secondShapePath];
            shapeTwo.physicsBody.velocity = self.physicsBody.velocity;
            //shapeTwo.physicsBody.angularVelocity = self.physicsBody.angularVelocity;
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
