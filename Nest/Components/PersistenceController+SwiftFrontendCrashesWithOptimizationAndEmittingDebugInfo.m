//
//  PersistenceController+SwiftFrontendCrashesWithOptimizationAndEmittingDebugInfo.m
//  Nest
//
//  Created by Manfred on 03/10/2016.
//
//

@import CoreData;
@import ObjectiveC;

#import <Nest/Nest-Swift.h>

@interface PersistentController(SwiftFrontendCrashesWithOptimizationAndEmittingDebugInfo)
@property (nonatomic, readonly) PersistentControllerState state;
@property (nonatomic, readonly) NSManagedObjectContext * fetchingContext;
@end

void PersistentControllerPerformBlockAndWait(
    PersistentController * self,
    SEL _cmd,
    void (^transaction) (NSManagedObjectContext * context)
    )
{
    PersistentControllerState state = [self state];
    
    switch (state) {
        case PersistentControllerStateReady: {
            [[self fetchingContext] performBlockAndWait: ^{
                transaction([self fetchingContext]);
            }];
            break;
        }
        case PersistentControllerStateNotPrepared: {
            while (
                [self state] == PersistentControllerStatePreparing
                || [self state] == PersistentControllerStateNotPrepared
            ) {}
            PersistentControllerPerformBlockAndWait(
                self, _cmd, transaction
            );
            break;
        }
        case PersistentControllerStatePreparing: {
            while ([self state] == PersistentControllerStatePreparing) {}
            PersistentControllerPerformBlockAndWait(
                self, _cmd, transaction
            );
            break;
        }
        case PersistentControllerStateFailed:
            [NSException raise:NSInternalInconsistencyException
                        format:@"Persistence controller initialization failed"];
            break;
    }
}


@implementation PersistentController(SwiftFrontendCrashesWithOptimizationAndEmittingDebugInfo)
@dynamic state;
@dynamic fetchingContext;

+ (void)load {
    class_replaceMethod(
        [PersistentController class],
        @selector(performBlockAndWait:),
        (IMP)&PersistentControllerPerformBlockAndWait,
        "@:@"
    );
}
@end
