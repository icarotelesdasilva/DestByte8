#include "Vtop.h"
#include "verilated.h"
#include <iostream>

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);
    Vtop* top = new Vtop;

    top->clk = 0;
    top->reset = 1;

    int cycle = 0;
    while (cycle < 20) {
        top->clk ^= 1;
        
        if (cycle == 4) top->reset = 0;

        top->eval();

        if (top->clk == 1) {
            std::cout << "Ciclo: " << cycle 
                      << " | Reset: " << (int)top->reset 
                      << " | Resultado ULA: " << (int)top->resultado_final << std::endl;
        }
        cycle++;
    }

    delete top;
    return 0;
}