module pc (
    input wire reset,
    input wire clk,
    input wire [7:0] pc_next,
    output reg [7:0] pc_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc_out <= 8'h00;
    end else begin
        pc_out <= pc_next;
    end
end

endmodule
