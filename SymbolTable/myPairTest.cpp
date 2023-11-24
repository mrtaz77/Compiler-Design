#include <iostream>
#include <cstring>
#include "myPair.h"

int main() {
    // Test with int
    myPair<int, int> intPair(10, 20);
    std::cout << "Int Pair: " << intPair << std::endl;

    // Test with float
    myPair<float, float> floatPair(3.14f, 2.718f);
    std::cout << "Float Pair: " << floatPair << std::endl;

    // Test with string
    myPair<std::string, std::string> stringPair("Hello", "World");
    std::cout << "String Pair: " << stringPair << std::endl;

    return 0;
}
