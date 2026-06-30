`timescale 1ns / 1ps

module Delay_TB;

    parameter ANCHO = 16;
    
    reg clk;
    reg reset;
    reg update;
    reg [ANCHO-1:0] in_val;

    wire [ANCHO-1:0] out_val;

    Delay #(
        .ANCHO(ANCHO)
    ) uut (
        .clk(clk),
        .reset(reset),
        .update(update),
        .in_val(in_val),
        .out_val(out_val)
    );

    always #10 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        update = 0;
        in_val = 0;

        #50;
        @(negedge clk); 
        reset = 0;

        $display("-----------------------------------------------------------------");

        in_val = 16'hAAAA;
        $display("[%0t] [TEST 1] Entrada = %h, Update = 0. Esperando flancos de reloj...", $time, in_val);
        
        repeat (2) @(posedge clk);
        #1; 
        
        if (out_val == 16'h0000) begin
            $display("[%0t] EXITO: La salida se mantuvo segura en %h", $time, out_val);
        end else begin
            $display("[%0t] ERROR: La salida cambio inesperadamente a %h", $time, out_val);
        end
        $display("-----------------------------------------------------------------");

        @(negedge clk); 
        update = 1;
        in_val = 16'h5555;
        $display("[%0t] [TEST 2] Entrada = %h, Update = 1. Aplicando flanco de captura...", $time, in_val);
        
        @(posedge clk);
        #1; 
        
        if (out_val == 16'h5555) begin
            $display("[%0t] EXITO: El dato se guardo en el registro correctamente: %h", $time, out_val);
        end else begin
            $display("[%0t] ERROR: Fallo al capturar. La salida es %h", $time, out_val);
        end
        $display("-----------------------------------------------------------------");

        @(negedge clk);
        update = 0;
        in_val = 16'hFFFF; 
        $display("[%0t] [TEST 3] Update = 0. Cambiamos la entrada a %h para forzar fallo...", $time, in_val);
        
        @(posedge clk);
        #1;
        
        if (out_val == 16'h5555) begin
            $display("[%0t] EXITO: El registro retuvo el valor anterior a la perfeccion: %h", $time, out_val);
        end else begin
            $display("[%0t] ERROR: El registro se contamino. Salida actual: %h", $time, out_val);
        end
        $display("-----------------------------------------------------------------");

        @(negedge clk);
        reset = 1;
        update = 1; 
        in_val = 16'h1234;
        $display("[%0t] [TEST 4] Aplicando Reset Sincrono. Entrada = %h y Update = 1", $time, in_val);
        
        @(posedge clk);
        #1;
        
        if (out_val == 16'h0000) begin
            $display("[%0t] EXITO: El Reset borro el registro respetando la jerarquia: %h", $time, out_val);
        end else begin
            $display("[%0t] ERROR: El Reset fallo o perdio prioridad. Salida: %h", $time, out_val);
        end
        $display("-----------------------------------------------------------------");
        
        #50;
        $stop;
    end

endmodule