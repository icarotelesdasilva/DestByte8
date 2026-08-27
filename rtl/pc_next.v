module pc_next (
    input  [7:0] pc,
    output [7:0] pc_next
);

assign pc_next = pc + 8'd1;

endmodule
