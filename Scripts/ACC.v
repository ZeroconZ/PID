module ACC #(
    parameter ANCHO = 16
)(
    input wire clk,
    input wire reset,
    input wire enable,
    input wire sub,
    input wire update_val,

    input wire signed [ANCHO-1:0] val,
    output reg signed [ANCHO-1:0] resultado
);

    reg signed [31:0] val_interno;
    

    wire signed [31:0] val_32;
    wire signed [31:0] val_adaptado;
    
    assign val_32 = val; 
    assign val_adaptado = val_32 <<< 15; 
    
    always @(posedge clk) begin
        if (reset) begin
            val_interno <= 0;
        end
        else if (enable) begin
            if (sub) begin
                val_interno <= (val_interno >>> 1) - val_adaptado;
            end
            else begin
                val_interno <= (val_interno >>> 1) + val_adaptado;
            end
        end
    end
    
    always @(posedge clk) begin
        if (update_val) begin
            resultado <= val_interno[27:12];
        end
    end

endmodule