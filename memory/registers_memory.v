    module registers_memory (
        input wire clk,

        input wire we,
        
        input wire reset,

        input wire [2:0] w_addr,

        input wire [2:0] r_addr1, 

        input wire [2:0] r_addr2, 

        input wire [7:0] w_data,

        output wire [7:0] r_data1,

        output wire [7:0] r_data2  
    );

        reg [7:0] T [0:7];

    integer i;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 8; i = i + 1)
                T[i] <= 8'h00;
        end else if (we) begin
            T[w_addr] <= w_data;
        end
    end

       assign r_data1 = T[r_addr1];
       assign r_data2 = T[r_addr2];

       endmodule
