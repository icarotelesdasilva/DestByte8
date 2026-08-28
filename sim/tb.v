
module tb_test;

reg [7:0] address_tb;
reg [7:0] write_data_tb;
reg write_enable_tb;
reg clk;
reg reset;

wire [7:0] result;
wire [7:0] pc_debug;

top dut (
    .clk(clk),
    .reset(reset),
    .result(result),
    .pc_debug(pc_debug)
);

always #5 clk = ~clk;


  /*
 
 * Warning: This code is just to keep the simulation 
 * of those who want to test close to the hardware, the cpu is not simulation.
 
 */

initial begin
    clk = 0;
    reset = 1;

    #20;

    reset = 0;

    dut.m_data_memory.write_enable = 1'b1;
    dut.m_data_memory.address = 8'h10;
    dut.m_data_memory.write_data = 8'h55;

    #10;

    dut.m_data_memory.write_enable = 1'b0;

    #10;

    $display("Memory[10] = %h", dut.m_data_memory.read_data);

    // Escreve 0xAA no endereço 0x20
    dut.m_data_memory.write_enable = 1'b1;
    dut.m_data_memory.address = 8'h20;
    dut.m_data_memory.write_data = 8'hAA;

    #10;

    dut.m_data_memory.write_enable = 1'b0;

    #10;

    $display("Memory[20] = %h", dut.m_data_memory.read_data);

    dut.m_data_memory.address = 8'h10;

    #10;

    $display("Memory[10] again = %h", dut.m_data_memory.read_data);

    $finish;
end

endmodule

