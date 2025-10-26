#include <iostream>

using namespace std;

unsigned long long factorial(unsigned int n) {
    if (n == 0 || n == 1)
        return 1;
    return n * factorial(n - 1);
}

int main() {
    unsigned int n;
    cout << "Введите число: ";
    cin >> n;

    cout << "Факториал " << n << " = " << factorial(n) << endl;
    return 0;
}
