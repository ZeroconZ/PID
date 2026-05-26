module Sensor_receiver #(
    parameter ANCHO = 16
)(
    input wire clk,         
    input wire reset,
    
    input wire clk_datos,   
    input wire ini_fin,     
    input wire bit_entrada, 
    
    output reg signed [ANCHO-1:0] Y,
    output reg start_tick
);

    reg sync_clk_datos_1, sync_clk_datos_2;
    reg sync_ini_fin_1, sync_ini_fin_2;
    reg sync_bit_entrada_1, sync_bit_entrada_2;

    always @(posedge clk) begin
        if (reset) begin
            sync_clk_datos_1 <= 0; 
            sync_clk_datos_2 <= 0;

            sync_ini_fin_1 <= 0;   
            sync_ini_fin_2 <= 0;

            sync_bit_entrada_1 <= 0; 
            sync_bit_entrada_2 <= 0;
        end 
        else begin
            sync_clk_datos_1 <= clk_datos;   
            sync_clk_datos_2 <= sync_clk_datos_1;

            sync_ini_fin_1   <= ini_fin;     
            sync_ini_fin_2   <= sync_ini_fin_1;

            sync_bit_entrada_1 <= bit_entrada; 
            sync_bit_entrada_2 <= sync_bit_entrada_1;
        end
    end

    reg clk_datos_anterior;
    wire flanco_subida_spi;
    wire flanco_bajada_ini;

    always @(posedge clk) begin
        if (reset) clk_datos_anterior <= 0;
        else clk_datos_anterior <= sync_clk_datos_2;
    end

    assign flanco_subida_spi = (clk_datos_anterior == 1'b0) && (sync_clk_datos_2 == 1'b1);

    reg [ANCHO-1:0] Y_temp;
    reg ini_fin_anterior;

    always @(posedge clk) begin
        if (reset) begin
            Y <= 0;
            Y_temp <= 0;
            ini_fin_anterior <= 0;
        end 
        else begin
            ini_fin_anterior <= sync_ini_fin_2;
            start_tick <= 0;
            if (sync_ini_fin_2 && flanco_subida_spi) begin
                Y_temp <= {Y_temp[ANCHO-2:0], sync_bit_entrada_2};
            end
            
            if (ini_fin_anterior == 1'b1 && sync_ini_fin_2 == 1'b0) begin
                Y <= Y_temp;
                Y_temp <= 0;
                start_tick <= 1;
            end
        end
    end

endmodule

