#import <SpriteKit/SpriteKit.h>

@interface SKShapeNode (Area)

// Computed on every request, change implementation if calling frequently.
-(float) area;

@end
