module tb_test;

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
  
  

  /*
 
 * Warning: This code is just to keep the simulation 
 * of those who want to test close to the hardware, the cpu is not simulation.
 
 */

always #5 clk = ~clk;

initial begin
    clk = 0;
    reset = 1;

    #20;

    reset = 0;

    dut.m_regs.T[1] = 8'h05;

    #20;

    $display("T0 = %h", dut.m_regs.T[0]);
    $display("T1 = %h", dut.m_regs.T[1]);
    $display("PC = %h", pc_debug);

    $finish;
end

endmodule
