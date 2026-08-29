						module data_memory (

						    input wire clk,
						    input wire [7:0] address,
						    input wire write_enable,
						    input wire [7:0] write_data,
						    output wire [7:0] read_data
						);

						reg [7:0] memory [0:255];

						always @(posedge clk) begin
							
							
							if (write_enable)
							
							memory[address] <= write_data;
							
						end
						assign read_data = memory[address];

						endmodule
