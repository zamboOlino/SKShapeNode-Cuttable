#import <SpriteKit/SpriteKit.h>
#import <AGGeometryKit.h>
#import "SKShapeNode+Area.h"

@interface SKShapeNode (Cuttable)

-(NSArray*)cutWithLine:(AGKLine)cutLine;

@end
