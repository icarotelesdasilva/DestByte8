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




module rom (

input wire [7:0] addr,
output reg [7:0] data


);

reg [7:0] memory [255:0];

initial begin
$readmemh("boot.hex", memory);
    end

    always @(*) begin
    data = memory[addr];
    
        end
        end
                endmodule


