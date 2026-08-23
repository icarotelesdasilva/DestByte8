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
        default: result = 8'h00;
    endcase
end

endmodule