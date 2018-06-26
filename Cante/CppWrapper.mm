//
//  NSObject+CppWrapper.m
//  Cante
//
//  Created by Adrián Camacho Gil on 23/3/18.
//  Copyright © 2018 cofla. All rights reserved.
//

#import "CppWrapper.h"
#include "CppClass.hpp"

@implementation CppWrapper

    CppClass instanceCpp;

    - (void)runCode:(NSString *)directoryToSong {
        // Converting directoryToSong type to std::string
        std::string directoryToSongString = std::string([directoryToSong UTF8String]);
        
        // Call Cpp Code
        instanceCpp.run(directoryToSongString);
    }
    
    - (NSMutableArray *)getCsv {
        std::vector<std::vector<float>> csvFile = instanceCpp.getCsv();

        NSMutableArray* result = [[NSMutableArray alloc] init];
        for(int i=0; i<csvFile[0].size(); i++) {
            NSMutableArray* fileArray = [[NSMutableArray alloc] init];
            for(int j=0; j<3; j++) {
                NSNumber* value = @(csvFile[j][i]);
                [fileArray addObject:value];
            }
            [result addObject:fileArray];
        }
        return result;
    }
    
@end
