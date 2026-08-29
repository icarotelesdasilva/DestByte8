                module tb_decoder;

                reg [7:0] instruction_tb;

                wire [2:0] alu_control_tb;
                wire [2:0] w_addr_tb;
                wire [2:0] r_addr1_tb;
                wire [2:0] r_addr2_tb;
                wire reg_we_tb;
                wire mem_we_tb;

                decoder dut (
                    .instruction(instruction_tb),
                    .alu_control(alu_control_tb),
                    .w_addr(w_addr_tb),
                    .r_addr1(r_addr1_tb),
                    .r_addr2(r_addr2_tb),
                    .reg_we(reg_we_tb),
                    .mem_we(mem_we_tb)
                );


                  /*
                 
                 * Warning: This code is just to keep the simulation 
                 * of those who want to test close to the hardware, the cpu is not simulation.
                 
                 */ 

                initial begin

                    instruction_tb = 8'b00001001;
                    #10;

                    $display(
                        "INST=%b ALU=%b W=%b R1=%b R2=%b REG_WE=%b MEM_WE=%b",
                        instruction_tb,
                        alu_control_tb,
                        w_addr_tb,
                        r_addr1_tb,
                        r_addr2_tb,
                        reg_we_tb,
                        mem_we_tb
                    );


                    instruction_tb = 8'b01001001;
                    #10;

                    $display(
                        "INST=%b ALU=%b W=%b R1=%b R2=%b REG_WE=%b MEM_WE=%b",
                        instruction_tb,
                        alu_control_tb,
                        w_addr_tb,
                        r_addr1_tb,
                        r_addr2_tb,
                        reg_we_tb,
                        mem_we_tb
                    );

                   
                    instruction_tb = 8'b10001001;
                    #10;

                    $display(
                        "INST=%b ALU=%b W=%b R1=%b R2=%b REG_WE=%b MEM_WE=%b",
                        instruction_tb,
                        alu_control_tb,
                        w_addr_tb,
                        r_addr1_tb,
                        r_addr2_tb,
                        reg_we_tb,
                        mem_we_tb
                    );

                    instruction_tb = 8'b11001001;
                    #10;

                    $display(
                        "INST=%b ALU=%b W=%b R1=%b R2=%b REG_WE=%b MEM_WE=%b",
                        instruction_tb,
                        alu_control_tb,
                        w_addr_tb,
                        r_addr1_tb,
                        r_addr2_tb,
                        reg_we_tb,
                        mem_we_tb
                    );

                    $finish;
                end

                endmodule

