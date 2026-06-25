`timescale 1ns / 1ps

module ACC #(
    parameter ANCHO = 16
)(
    input  wire clk,
    input  wire reset,
    input  wire enable,
    input  wire sub,
    input  wire update_val,

    input  wire signed [ANCHO-1:0] val,
    output reg  signed [ANCHO-1:0] resultado
);

    // Registro acumulador de doble precisión (32 bits) para evitar desbordamientos
    reg signed [31:0] val_interno;
    
    // Señales combinacionales para la adaptación de formato
    wire signed [31:0] val_32;
    wire signed [31:0] val_adaptado;
    
    // Extensión de signo automática (de 16 a 32 bits)
    assign val_32 = val; 
    
    // Alineación del valor de la LUT multiplicando por 2^15
    assign val_adaptado = val_32 <<< 15; 
    
    // Bloque secuencial principal: Control del Acumulador y Actualización de Salida
    always @(posedge clk) begin
        if (reset) begin
            val_interno <= 32'sd0;
            resultado   <= {ANCHO{1'b0}}; // CORRECCIÓN: Inicialización obligatoria a 0
        end
        else begin
            // 1. Lógica de acumulación iterativa de la Aritmética Distribuida
            if (enable) begin
                if (sub) begin
                    // Último ciclo (Bit de signo de la entrada): Se resta el valor
                    val_interno <= (val_interno >>> 1) - val_adaptado;
                end
                else begin
                    // Ciclos estándar: Desplazamiento aritmético a la derecha y suma
                    val_interno <= (val_interno >>> 1) + val_adaptado;
                end
            end
            
            // 2. Lógica de latcheo del resultado final
            if (update_val) begin
                // Extracción de la ventana [27:12] para retornar al formato Q4.12
                resultado <= val_interno[27:12];
            end
        end
    end

endmodule