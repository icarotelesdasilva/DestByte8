module top (
    input wire clk,
    input wire reset
);

    wire [7:0] endereco_fio;
    wire [7:0] dado_fio;

    pc meu_pc (
        .clk(clk),
        .reset(reset),
        .pc_out(endereco_fio)   
    );

    rom minha_rom (
        .addr(endereco_fio),     
        .data(dado_fio)          
    );

endmodule