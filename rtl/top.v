
                        // Copyright (C) 2026 icaro teles da silva ribeiro (@icarotelesdasilva)
                        // Licensed under the CERN Open Hardware Licence Version 2 - Strongly Reciprocal (CERN-OHL-S)

                        module top (
                            input wire clk,
                            input wire reset,
                            output wire [7:0] result,
                            output wire [7:0] pc_debug
                        );
                            wire mem_we;
                            wire [7:0] next_pc;
                            wire [7:0] end_pc;
                            wire [7:0] dd;
                            wire [7:0] memory_read_data;
                            wire [2:0] cf;
                            wire reg_we;

                            wire [2:0] w_addr;
                            wire [2:0] r_addr1;
                            wire [2:0] r_addr2;

                            wire [7:0] r_data1;
                            wire [7:0] r_data2;
                            wire [7:0] alu_result;
                            wire [7:0] memory_read_data;

                            pc my_pc (
                                .clk(clk),
                                .reset(reset),
                                .pc_out(end_pc),
                                .pc_next(next_pc)
                            );

                            pc_next my_pc_next (
                                .pc(end_pc),
                                .pc_next(next_pc)
                            );

                            rom m_rom (
                                .addr(end_pc),
                                .data(dd)
                            );

                            decoder _decoder (
                                .instruction(dd),
                                .alu_control(cf),
                                .w_addr(w_addr),
                                .r_addr1(r_addr1),
                                .r_addr2(r_addr2),
                                .reg_we(reg_we),
                                .mem_we(mem_we)
                            );

                            registers_memory m_regs (
                                .clk(clk),
                                .we(reg_we & ~reset),
                                .w_addr(w_addr),
                                .reset(reset),
                                .r_addr1(r_addr1),
                                .r_addr2(r_addr2),
                                .w_data(alu_result),
                                .r_data1(r_data1),
                                .r_data2(r_data2)
                            );

                            alu m_alu (
                                .a(r_data1),
                                .b(r_data2),
                                .alu_control(cf),
                                .result(alu_result)
                            );

                            
                            data_memory m_data_memory (
                                .clk(clk),
                                .address(r_data2), 
                                .write_enable(mem_we),
                                .write_data(r_data1),
                                .read_data(memory_read_data)
                                

                            );

                            assign result = alu_result;
                            assign pc_debug = end_pc;

                        endmodule
