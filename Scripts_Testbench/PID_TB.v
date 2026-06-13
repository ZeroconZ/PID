`timescale 1ns / 1ps

module system_TB;
    parameter ANCHO = 16;
    
    // ENTRADAS
    reg clk;
    reg reset;

    reg clk_datos;
    reg ini_fin;
    reg bit_entrada;
    
    reg [ANCHO-1:0] Uc; 

    wire PWM_pulse;

    // VARIABLES DE CONTROL LOCALES DEL TESTBENCH
    reg signed [ANCHO-1:0] Feedback;

    // INSTANCIACIÓN DEL DUT
    PID #(
        .ANCHO(ANCHO) // Aquí sí pasamos parámetros
    ) uut (
        .Uc(Uc),      
        .clk(clk),
        .reset(reset),
        .clk_datos(clk_datos),
        .ini_fin(ini_fin),
        .bit_entrada(bit_entrada),
        .PWM_pulse(PWM_pulse)
    );

    // RELOJ FPGA (50 MHZ)
    always #10 clk = ~clk;

    task send_spi_data;
        input [15:0] data_to_send; 
        integer i;
        begin
            // INICIO TRANSMISIÓN
            ini_fin = 1;
            #100;

            // ENVIO DEL ESP32 (MSB First)
            for (i = 15; i >= 0; i = i - 1) begin
                bit_entrada = data_to_send[i];
                #100;          
                clk_datos = 1; 
                #200;          
                clk_datos = 0; 
                #100;          
            end

            // FIN TRANSMISIÓN
            #100;
            ini_fin = 0;
            #100; // Dejar un margen antes de la siguiente trama
        end
    endtask

    // SECUENCIA DE ESTÍMULOS
    initial begin 
        // Inicialización
        clk = 0;
        reset = 1;
        clk_datos = 0;
        ini_fin = 0;
        bit_entrada = 0;
        Uc = 16'b0100000000000000; // Setpoint en 4.0

        // LIMPIEZA DEL CONTROLADOR
        #100;
        reset = 0;
        #100;

        $display("[%0t] -----------------------------------------------------------------", $time);

        // --- PRUEBA 1: Muestra inicial (Evaluando P) ---
        Feedback = 16'd0;
        $display("[%0t] Envio de un valor: %d", $time, Feedback);
        send_spi_data(Feedback);

        @(posedge uut.start_tick); // Esperar a que el receptor serial termine
        if(Feedback == uut.Y) $display("[%0t] [MONITOR] Rx OK: Y = %d", $time, uut.Y);
        else $display("[%0t] [MONITOR] Hubo un problema papu en Rx", $time);

        @(posedge uut.resultado_ready); // Esperar cálculo DA
        $display("[%0t] [MONITOR] Calculo completado -> ACC_P=%d, I=%d, PID=%d", $time, uut.ACC_P_res, uut.I, uut.RESULTADO_PID);

        // --- PRUEBA 2: Nueva muestra (Evaluando I y D) ---
        #5000; // Esperar un poco
        Feedback = 16'b0001000000000000; // Simular que la temperatura subió (Y = 1.0)
        $display("\n[%0t] Envio de nueva muestra: %d", $time, Feedback);
        send_spi_data(Feedback);
        
        @(posedge uut.resultado_ready);
        $display("[%0t] [MONITOR] Calculo completado -> ACC_P=%d, I=%d, PID=%d", $time, uut.ACC_P_res, uut.I, uut.RESULTADO_PID);

        // Esperar lo suficiente para ver una iteración completa del módulo PWM
        // El periodo base suele requerir miles de ciclos a 50MHz
        #1000000; 
        
        $display("[%0t] Fin de la simulacion.", $time);
        $stop;
    end

endmodule