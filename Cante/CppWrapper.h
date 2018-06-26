//
//  NSObject+CppWrapper.h
//  Cante
//
//  Created by Adrián Camacho Gil on 23/3/18.
//  Copyright © 2018 cofla. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CppWrapper: NSObject
    
    - (void)runCode:(NSString *)directoryToSong;
    - (NSMutableArray *)getCsv;
    
@end

