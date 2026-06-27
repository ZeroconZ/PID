`timescale 1ns / 1ps

module Final_adder #(
    parameter ANCHO = 16,
    parameter signed [17:0] MAX_LIMIT = 18'sd32767, 
    parameter signed [17:0] MIN_LIMIT = -18'sd32768 
)(
    input  wire clk,
    input  wire reset,
    input  wire update, 

    input  wire signed [ANCHO-1:0] P_in,
    input  wire signed [ANCHO-1:0] I_in,
    input  wire signed [ANCHO-1:0] D_in,

    output reg  signed [ANCHO-1:0] U_out,
    output reg  out_ready 
);

    wire signed [17:0] P_ext;
    wire signed [17:0] I_ext;
    wire signed [17:0] D_ext;
    
    assign P_ext = P_in;
    assign I_ext = I_in;
    assign D_ext = D_in;

    wire signed [17:0] suma_total;
    assign suma_total = P_ext + I_ext + D_ext;

    always @(posedge clk) begin
        if (reset) begin
            U_out     <= {ANCHO{1'b0}};
            out_ready <= 1'b0;
        end 
        else begin
            out_ready <= update; 
            
            if (update) begin
                if (suma_total > MAX_LIMIT) begin
                    U_out <= MAX_LIMIT[ANCHO-1:0];
                end 
                else if (suma_total < MIN_LIMIT) begin
                    U_out <= MIN_LIMIT[ANCHO-1:0];
                end 
                else begin
                    U_out <= suma_total[ANCHO-1:0];
                end
            end
        end
    end

endmodule