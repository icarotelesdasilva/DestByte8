module tb_memory;

reg clk;
reg [7:0] address;
reg write_enable;
reg [7:0] write_data;
wire [7:0] read_data;

data_memory dut (
    .clk(clk),
    .address(address),
    .write_enable(write_enable),
    .write_data(write_data),
    .read_data(read_data)
);

always #5 clk = ~clk;

initial begin
    clk = 0;
    address = 8'h00;
    write_enable = 1'b0;
    write_data = 8'h00;

    #10;
    address = 8'h10;
    write_data = 8'h55;
    write_enable = 1'b1;

  /*
 
 * Warning: This code is just to keep the simulation 
 * of those who want to test close to the hardware, the cpu is not simulation.
 
 */
    #10;
    write_enable = 1'b0;

    #1;
    $display("Memory[10] = %h", read_data);

    #9;
    address = 8'h20;
    write_data = 8'hAA;
    write_enable = 1'b1;

    #10;
    write_enable = 1'b0;

    #1;
    $display("Memory[20] = %h", read_data);

    address = 8'h10;

    #1;
    $display("Memory[10] again = %h", read_data);

    $finish;
end

endmodule
