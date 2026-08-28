module pc_formal;

    reg clk;
    reg reset;

    wire [7:0] pc_next;
    wire [7:0] pc_out;

    pc_next next_logic (
        .pc(pc_out),
        .pc_next(pc_next)
    );

    pc dut (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc_out(pc_out)
    );

    always @(posedge clk) begin
        if (reset)
            assert(pc_out == 8'h00);
    end

    initial begin
        assume(reset);
    end

endmodule
