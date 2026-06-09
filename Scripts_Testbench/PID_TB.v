`timescale 1ns / 1ps

module system_TB;
    parameter ANCHO = 16;
    parameter Uc = 0;

    // ENTRADAS
    reg clk;
    reg reset;

    reg clk_datos;
    reg ini_fin;
    reg bit_entrada;

    wire PWM_pulse;

    // VARIABLES DE CONTROL LOCALES DEL TESTBENCH
    reg signed [ANCHO-1:0] Feedback;

    // INSTANCIACIÓN DEL DUT
    PID #(
        .Uc(Uc)
    )uut(
        .clk(clk),
        .reset(reset),

        .clk_datos(clk_datos),
        .ini_fin(ini_fin),
        .bit_entrada(bit_entrada),

        .PWM_pulse(PWM_pulse)
    );

    //RELOJ FPGA (50 MHZ)
    always #10 clk = ~clk;

    task send_spi_data;
        input [15:0] data_to_send; 
        integer i;
        begin
            // INICIO TRANSMISIÓN
            ini_fin = 1;
            #100;

            // ENVIO DEL ESP32
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
            #20;

        end
    endtask

    //SECUENCIA DE ESTÍMULOS
    initial begin 
        clk = 0;
        reset = 1;
        clk_datos = 0;
        ini_fin = 0;
        bit_entrada = 0;

        Feedback = 16'd0;
        //LIMPIEZA DEL CONTROLADOR
        #50;
        reset = 0;
        #50;

        $display("[%0t] -----------------------------------------------------------------", $time);

        //PRUEBA BÁSICA
        Feedback = 16'd0;
        $display("[%0t] Envio de un valor: %d", $time, Feedback);
        send_spi_data(Feedback);

        @(posedge uut.start_tick);
        #1;

        if(Feedback == uut.Y) begin
            $display("[%0t] [MONITOR CDC] La señal se proceso bien", $time);
        end
        else begin
            $display("[%0t] [MONITOR CDC] Hubo un problema papu", $time);
        end

        @(posedge uut.resultado_ready);
        #1;
        $display("[%0t] [MONITOR CDC] ACCION P=%d", $time, uut.ACC_P_res);
        
        #200;
        $stop;
    end

endmodule
