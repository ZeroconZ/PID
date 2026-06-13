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

    // 1. Acumulador expandido a 32 bits (Formato Q8.24)
    reg signed [31:0] val_interno;
    
    // 2. Extensión de signo segura y pre-desplazamiento para la DA
    // (Separamos la declaración de la asignación para máxima compatibilidad)
    wire signed [31:0] val_32;
    wire signed [31:0] val_adaptado;
    
    assign val_32 = val; // Extiende el signo automáticamente a 32 bits
    assign val_adaptado = val_32 <<< 15; 
    
    always @(posedge clk) begin
        if (reset) begin
            val_interno <= 0;
        end
        else if (enable) begin
            if (sub) begin
                // En el ciclo del MSB se RESTA
                val_interno <= (val_interno >>> 1) - val_adaptado;
            end
            else begin
                // En los ciclos normales se SUMA
                val_interno <= (val_interno >>> 1) + val_adaptado;
            end
        end
    end
    
    always @(posedge clk) begin
        if (reset) begin 
            resultado <= 0;
        end
        else if (update_val) begin
            // 3. RECUPERACIÓN DEL FORMATO Q4.12
            // Extraemos los 16 bits del centro (27 al 12)
            resultado <= val_interno[27:12];
        end
    end

endmodule