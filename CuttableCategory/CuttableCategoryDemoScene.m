/*
 * Demo Scene of SKSHapeNode+Cuttable.
 */
#import "CuttableCategoryDemoScene.h"
#import <AGGeometryKit.h>
#import "SKShapeNode+Cuttable.h"
#import "SKShapeNode+Area.h"

@interface CuttableCategoryDemoScene()
{
    CGPoint _touchesBeganPoint;
    SKShapeNode* _cut;
}
@end

@implementation CuttableCategoryDemoScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
        
        // Draw platform for cuttable block to rest on
        SKSpriteNode* platform = [[SKSpriteNode alloc] initWithColor:[SKColor whiteColor]
                                                                size:CGSizeMake(40.0f, 20.0f)];
        platform.position = CGPointMake(self.size.width/2, self.size.height/4);
        platform.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:platform.size];
        platform.physicsBody.dynamic = NO;
        [self addChild:platform];
        
        // Draw floor for blocks to fall onto
        SKSpriteNode* floor = [[SKSpriteNode alloc] initWithColor:[SKColor blackColor]
                                                             size:CGSizeMake(self.size.width, 10.0f)];
        floor.position = CGPointMake(self.size.width/2, 5.0f);
        floor.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.size.width, 10.0f)];
        floor.physicsBody.dynamic = NO;
        [self addChild:floor];
        
        // Draw the cuttable block
        SKShapeNode* cuttableBlock = [[SKShapeNode alloc] init];
        CGMutablePathRef cutPath = CGPathCreateMutable();
        CGPathMoveToPoint(cutPath, NULL, self.size.width/2 - 50.0f, 240.0f);
        CGPathAddLineToPoint(cutPath, NULL,self.size.width/2 + 50.0f, 240.0f);
        CGPathAddLineToPoint(cutPath, NULL,self.size.width/2 + 50.0f, 340.0f);
        CGPathAddLineToPoint(cutPath, NULL,self.size.width/2 - 50.0f, 340.0f);
        CGPathAddLineToPoint(cutPath, NULL,self.size.width/2 - 50.0f, 240.0f);
        cuttableBlock.path = cutPath;
        cuttableBlock.fillColor = [SKColor redColor];
        cuttableBlock.strokeColor = [SKColor redColor];
        
        cuttableBlock.physicsBody = [SKPhysicsBody bodyWithPolygonFromPath:cutPath];
        [self addChild:cuttableBlock];
        
        // Reduce gravity
        self.physicsWorld.gravity = CGVectorMake(0.0f, -1.0f);
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        _touchesBeganPoint = [touch locationInNode:self];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches.count == 1) {
        CGPoint touchPosition = [touches.allObjects.firstObject locationInNode:self];
        
        // Draw the cut graphic
        [_cut removeFromParent];
        _cut = [[SKShapeNode alloc] init];
        _cut.strokeColor = [SKColor whiteColor];
        _cut.lineWidth = 3;
        CGMutablePathRef cutPath = CGPathCreateMutable();
        CGPathMoveToPoint(cutPath, NULL, _touchesBeganPoint.x, _touchesBeganPoint.y);
        CGPathAddLineToPoint(cutPath, NULL,touchPosition.x, touchPosition.y);
        _cut.path = cutPath;
        [self addChild:_cut];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (touches.count == 1) {
        CGPoint touchPoint = [touches.allObjects.firstObject locationInNode:self];
        AGKLine cutLine = AGKLineMake(_touchesBeganPoint, touchPoint);
        
        // Cut any objects in cutLine
        for (SKNode* shapePossibleToCut in self.children) {
            if ([shapePossibleToCut class] == [SKShapeNode class]) {
                NSArray* newBlocks = [((SKShapeNode *)shapePossibleToCut) cutWithLine:cutLine];
                if ([newBlocks count] >= 2) { // Object is able to be cut
                    for (SKSpriteNode* node in newBlocks) {
                        if(![node isEqual:[NSNull null]]) {
                            [self addChild:node];
                            NSLog(@"Size of new node %f", [((SKShapeNode *)node) area]);
                        }
                    }
                    [shapePossibleToCut removeFromParent];
                }
            }
        }
        
        // Remove the cut graphic
        [_cut runAction:[SKAction sequence:@[[SKAction waitForDuration:0.05f],
                                             [SKAction customActionWithDuration:0.1f
                                                                    actionBlock:^(SKNode *node, CGFloat elapsedTime) {
                                                                        [node removeFromParent];
                                                                    }]]]];
    }
}

@end

