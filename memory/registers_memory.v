module registers_memory (
    input wire clk,

    input wire we,
    
    input wire [2:0] w_addr,

    input wire [2:0] r_addr1, 

    input wire [2:0] r_addr2, 

    input wire [7:0] w_data,

    output wire [7:0] r_data1,

    output wire [7:0] r_data2  
);

    reg [7:0] T [0:7];

    always @(posedge clk) begin
        if (we) begin
            T[w_addr] <= w_data;
        end
    end

   assign r_data1 = T[r_addr1];
   assign r_data2 = T[r_addr2];

   endmodule
