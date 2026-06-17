`timescale 1ns / 1ps

module system_TB;
    parameter ANCHO = 16;
    
    // ENTRADAS
    reg clk;
    reg reset;

    reg clk_datos;
    reg ini_fin;
    reg bit_entrada;
    
    parameter signed [ANCHO-1:0] Uc = 16'd16384; 

    wire PWM_pulse;

    // VARIABLES DE CONTROL LOCALES DEL TESTBENCH
    reg signed [ANCHO-1:0] Feedback;
    integer j; 

    // INSTANCIACIÓN DEL DUT
    PID #(
        .ANCHO(ANCHO),
        .Uc(Uc)
    ) uut (    
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
            #100; 
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

        // LIMPIEZA DEL CONTROLADOR
        #100;
        reset = 0;
        #100;

        $display("=================================================================");
        $display("PRUEBA");
        $display("=================================================================\n");

        Feedback = 16'd384; 

        for (j = 1; j <= 6; j = j + 1) begin
            $display("--- ENVIANDO MUESTRA %0d ---", j);
            
            fork
                begin
                    send_spi_data(Feedback);
                end
                begin
                    @(posedge uut.start_tick); 
                end
            join

            if(Feedback == uut.Y) $display("[%0t] [MONITOR] Rx OK: Y = %d", $time, uut.Y);
            else $display("[%0t] [MONITOR] Hubo un problema papu en el envio", $time);
 
            @(posedge uut.resultado_ready);
            @(posedge clk); 

            // MONITOR DE VARIABLES
            $display("Tiempo %0t:", $time);
            $display("   -> Accion P (Instantanea) = %d", uut.ACC_P_res);
            $display("   -> Incremento I del ciclo = %d", uut.ACC_I_res);
            $display("   -> INTEGRAL TOTAL (I)     = %d", uut.I);
            $display("   -> INTEGRAL RETARDADA (I k-1)     = %d", uut.Delay_I_Out);
            $display("   -> RESULTADO PID          = %d\n", uut.RESULTADO_PID);

            #5000; 
        end

        #1000000; 
        
        $display("[%0t] Fin de la simulacion.", $time);
        $stop;
    end

endmodule