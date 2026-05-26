module Delay #(
	parameter ANCHO = 16
)
(
    input wire clk,
    input wire reset,  
    input wire update,
    
    input wire [ANCHO-1:0] in_val,   
    output reg [ANCHO-1:0] out_val   
);

    always @(posedge clk) begin
        if (reset) begin
            out_val <= 0; 
        end 
        else if (update) begin
            out_val <= in_val;
        end
    end

endmodule