// Copyright (C) 2026 icaro teles da silva ribeiro (@icarotelesdasilva)
// Licensed under the CERN Open Hardware Licence Version 2 - Strongly Reciprocal (CERN-OHL-S)

module decoder (
    input wire [7:0] instruction,
    output reg [2:0] alu_control,
    output reg [2:0] w_addr,
    output reg [2:0] r_addr1,
    output reg [2:0] r_addr2,
    output reg reg_we
);

always @(*) begin
    alu_control = 3'b000;
    w_addr      = instruction[5:3];
    r_addr1     = instruction[5:3]; 
    r_addr2     = instruction[2:0];
    reg_we      = 1'b0;

    case (instruction[7:6])
        2'b00: begin // Exemplo: ADD T_dest, T_src
            alu_control = 3'b000;
            reg_we      = 1'b1;  
        end
        
        2'b01: begin // Exemplo: SUB T_dest, T_src
            alu_control = 3'b001; 
            reg_we      = 1'b1;
        end
        
        default: begin
            alu_control = 3'b000;
            reg_we      = 1'b0;
        end
    endcase
end

endmodule
