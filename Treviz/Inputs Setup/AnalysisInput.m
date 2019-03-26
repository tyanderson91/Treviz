//
//  AnalysisInputs.m
//  temp
//
//  Created by Tyler Anderson on 10/4/18.
//  Copyright © 2018 Tyler Anderson. All rights reserved.
//

/*
#import "AnalysisInput.h"

static NSMutableArray<AnalysisInput*>* allParams;

@implementation AnalysisInput

+(void) initialize
{
    if (!allParams){
        [AnalysisInput resetAllParams];
    }
}

+ (void)addParam:(AnalysisInput*) input{
    [allParams addObject:input];
}

+ (void)removeParams:(AnalysisInput*) input{
    [allParams removeObject:input];
    input.isParam = NO;
}
+ (NSMutableArray<AnalysisInput*>*) getAllParams{
    return allParams;
}
+ (void) resetAllParams{
    allParams = [[NSMutableArray alloc] init];
}


- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _name = dict[@"DisplayName"];
        NSString* curVal = dict[@"Value"];
        _value = [curVal length]>0 ? curVal : @"--";
        NSString* curUnits = dict[@"Units"];
        _units = [curUnits length]>0 ? curUnits : @"--";
        _children = [NSMutableArray array];
        _checkValid = [[dict objectForKey:@"checkValid"] boolValue];
        _isValid = [[dict objectForKey:@"isValid"] boolValue];
        _isParam = [dict[@"isParam"] boolValue];
        _itemType = dict[@"itemType"];
        _inputType = dict[@"valueType"];

        if (_isParam){
            [AnalysisInput addParam:self];
        }
    }
    return self;
}


+ (NSMutableArray<AnalysisInput *> *)inputList:(NSString *)fileName
{
    //NSMutableArray<AnalysisInput *> *inputs= [NSMutableArray array];
    NSArray *inputList = [NSArray arrayWithContentsOfFile:fileName];
    NSMutableArray<AnalysisInput *> *inputs = recursPopulateList(inputList);
    return inputs; // po ((Feed *)feeds[0]).children
}

NSMutableArray<AnalysisInput *>* recursPopulateList(NSArray* input){ //fixit: for some reason, inputs are getting initialized twice
    NSMutableArray<AnalysisInput *> *output= [NSMutableArray array];
    for (NSDictionary *curProps in input){
        AnalysisInput *curInput = [[AnalysisInput alloc] initWithDictionary:curProps];
        if (![[curInput itemType] isEqualToString:@"variable"]){
            NSMutableArray<AnalysisInput *>* curOutput = recursPopulateList(curProps[@"items"]);
            curInput.children = curOutput;
        }
        [output addObject:curInput];
    }
    return output;
}

- (BOOL) hasParams{
    if ([self.itemType isEqualToString:@"variable"]){
        return self.isParam;
    }
    else if ([self.itemType isEqualToString:@"header"] || [self.itemType isEqualToString:@"subHeader"]){
        BOOL hasParams = NO;
        for (AnalysisInput* curChild in self.children){
            hasParams = (hasParams || [curChild hasParams]);
        }
        return hasParams;
    }
    return NO;
}

@end
*/
