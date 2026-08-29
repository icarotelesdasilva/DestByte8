// Copyright (C) 2026 icaro teles da silva ribeiro (@icarotelesdasilva)
// Licensed under the CERN Open Hardware Licence Version 2 - Strongly Reciprocal (CERN-OHL-S)



                module rom (
                    input wire [7:0] addr,
                    output wire [7:0] data
                );

                    reg [7:0] memory [0:255];

                    initial begin
                        memory[0] = 8'h81; 
                        memory[1] = 8'h20;
                    end

                    assign data = memory[addr];

                endmodule
