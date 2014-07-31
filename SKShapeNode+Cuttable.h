#import <SpriteKit/SpriteKit.h>
#import <AGGeometryKit.h>

@interface SKShapeNode (Cuttable)

-(NSArray*)cutWithLine:(AGKLine)cutLine;

@end
