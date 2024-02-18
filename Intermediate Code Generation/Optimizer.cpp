#define ASM_FILE "code.asm"
#define OPTIMIZED_ASM_FILE "optimized_code.asm"

#include <iostream>
#include <vector>
#include <string>

#include "OptimalASMUtil.h"

using namespace std;

int main() {
	peepHoleOptimization(ASM_FILE,OPTIMIZED_ASM_FILE);
}