// Copyright (C) 2026 icaro teles da silva ribeiro (@icarotelesdasilva)
// Licensed under the CERN Open Hardware Licence Version 2 - Strongly Reciprocal (CERN-OHL-S)

                        module alu (
                            input wire [7:0] a,
                            input wire [7:0] b,
                            input wire [2:0] alu_control,
                            output reg [7:0] result
                        );

                        always @(*) begin
                            case (alu_control)
                                3'b000: result = a + b; 
                                3'b001: result = a - b; 
                                3'b010: result = b;
                                default: result = 8'h00;
                            endcase
                        end

                        endmodule
