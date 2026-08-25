#include "Vtop.h"
#include "verilated.h"
#include <iostream>

// Copyright (C) 2026 icaro teles da silva ribeiro (@icarotelesdasilva)
// Licensed under the CERN Open Hardware Licence Version 2 - Strongly Reciprocal (CERN-OHL-S)

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
            std::cout << "Cicle: " << cycle 
                      << " | Reset: " << (int)top->reset 
                      << " | RESULT f: " << (int)top->result << std::endl;
        }
        cycle++;
    }

    delete top;
    return 0;
}