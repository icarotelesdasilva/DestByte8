                    module control_unit (
                        input  wire clk,
                        input  wire reset
                    );

                        localparam FETCH         = 3'b000;
                        localparam DECODE        = 3'b001;
                        localparam FETCH_OPERAND = 3'b010;
                        localparam EXECUTE       = 3'b011;
                        localparam WRITE_BACK    = 3'b100;

                        reg [2:0] state;
                        reg [2:0] next_state;

                    endmodule