module decoder (
    input wire [7:0] instruction,
    output reg [2:0] alu_control  
);

always @(*) begin
    case (instruction[7:5]) 
        3'b000: begin
            alu_control = 3'b000; 
        end
        
        3'b001: begin
            alu_control = 3'b001; 
        end
        
        default: begin
            alu_control = 3'b000; 
        end
    endcase
end

endmodule