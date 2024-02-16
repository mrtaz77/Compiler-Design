#define ASM_FILE "suboptimal_code.asm"

#include <iostream>
#include <vector>
#include <string>

#include "OptimalASMUtil.h"

using namespace std;

int main() {
	peepHoleOptimization(ASM_FILE,"optimized_code.asm");
}