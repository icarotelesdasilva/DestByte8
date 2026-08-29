                #include "Vtop.h"
                #include "verilated.h"
                #include <iostream>
                #include <iomanip>

                // Copyright (C) 2026 icaro teles da silva ribeiro (@icarotelesdasilva)
                // Licensed under the CERN Open Hardware Licence Version 2 - Strongly Reciprocal (CERN-OHL-S)

                static void tick(Vtop* top)
                {
                    top->clk = 0;
                    top->eval();

                    top->clk = 1;
                    top->eval();
                }

                static void debug_cpu(Vtop* top, int cycle)
                {
                    std::cout
                        << "CYCLE      : " << std::dec << cycle << "\n"
                        << "RESET      : " << (int)top->reset << "\n"
                        << "PC         : 0x"
                        << std::hex << std::setw(2) << std::setfill('0')
                        << (int)top->pc_debug
                        << "\n"
                        << "RESULT     : 0x"
                        << std::setw(2)
                        << (int)top->result
                        << "\n";

                    

                    std::cout << std::dec;
                }

                int main(int argc, char** argv)
                {
                    Verilated::commandArgs(argc, argv);

                    Vtop* top = new Vtop;

                    top->clk = 0;
                    top->reset = 1;

                    std::cout << "\n";
                    std::cout << "DestByte8 CPU DEBUG\n";


                    std::cout << "\n[ RESET ]\n";

                    for (int i = 0; i < 2; i++)
                    {
                        tick(top);
                        debug_cpu(top, i);
                    }


                    top->reset = 0;

                    std::cout << "\n CPU EXECUTION \n";

                    

                    for (int cycle = 0; cycle < 32; cycle++)
                    {
                        tick(top);
                        debug_cpu(top, cycle + 2);
                    }

                    std::cout << "\n";
                    std::cout << " TEST FINISHED\n";

                    delete top;

                    return 0;
                }

