module top (
    input wire clk,
    input wire reset,
    output wire [7:0] resultado_final
);

    wire [7:0] end_pc;
    wire [7:0] dd;
    wire [2:0] cf;

    pc my_pc (
        .clk(clk),
        .reset(reset),
        .pc_out(end_pc)    
    );

    rom m_rom (
        .addr(end_pc),     
        .data(dd)         
    );

    decoder _decoder (
        .instruction(dd),      
        .alu_control(cf)       
    );

    alu m_alu (
        .a(8'd4),              
        .b(8'd2),              
        .alu_control(cf),      
        .result(resultado_final)
    );

endmodule

