//
//  CppClass.hpp
//  Cante
//
//  Created by Adrián Camacho Gil on 23/3/18.
//  Copyright © 2018 cofla. All rights reserved.
//

#include <stdio.h>
#include <iostream>

#include <string>
#include <vector>

class CppClass {
    public:
    CppClass() {}
    
    int run(std::string directorio);
    std::vector<std::vector<float>> getCsv();
    
};
