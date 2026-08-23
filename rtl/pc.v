// Copyright (C) 2026 icaro teles da silva ribeiro (@icarotelesdasilva)
// Licensed under the CERN Open Hardware Licence Version 2 - Strongly Reciprocal (CERN-OHL-S)



module pc (

input wire reset,
input wire clk,
output reg [7:0] pc_out

);

always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc_out <= 8'h00;    
        end else begin
            pc_out <= pc_out + 8'd1; 
        end
    end

endmodule
