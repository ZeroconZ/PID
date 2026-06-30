`timescale 1ns / 1ps

module tb_Sensor_receiver;

    parameter ANCHO = 16;
    
    // ENTRADAS
    reg clk;
    reg reset;
    reg clk_datos;
    reg ini_fin;
    reg bit_entrada;

    // VARIABLES DE CONTROL LOCALES DEL TESTBENCH
    reg signed [ANCHO-1:0] pos_val;
    reg signed [ANCHO-1:0] neg_val;

    // SALIDAS
    wire signed [ANCHO-1:0] Y;
    wire start_tick;

    // INSTANCIACIÓN DEL DUT
    Sensor_receiver #(
        .ANCHO(ANCHO)
    ) uut (
        .clk(clk),
        .reset(reset),

        .clk_datos(clk_datos),
        .ini_fin(ini_fin),
        .bit_entrada(bit_entrada),
        
        .Y(Y),
        .start_tick(start_tick)
    );

    // RELOJ SISTEMA (50 MHz)
    always #10 clk = ~clk;

    // TAREA DE TRANSMISIÓN SERIAL
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

        end
    endtask

    // SECUENCIA DE ESTÍMULOS
    initial begin
        clk = 0;
        reset = 1;
        clk_datos = 0;
        ini_fin = 0;
        bit_entrada = 0;

        // LIMPIEZA DEL CONTROLADOR
        #50;
        reset = 0;
        #50;

        $display("[%0t] -----------------------------------------------------------------", $time);

        // PRUEBA VALOR POSITIVO
        pos_val = 16'd2048;
        $display("[%0t] Envio de un valor positivo: %d", $time, pos_val);
        send_spi_data(pos_val);
        
        @(posedge start_tick);
        #1;

        if(Y == pos_val) begin
            $display("[%0t] El valor recibido es: %d ", $time, Y);
        end
        else begin
            $display("[%0t] No se recibió el valor correctamente", $time);
        end

        $display("[%0t] -----------------------------------------------------------------", $time);

        // PRUEBA VALOR NEGATIVO
        #500;

        neg_val = 16'd51200;
        $display("[%0t] Envio de un valor negativo: %d", $time, neg_val); // Corregido texto
        send_spi_data(neg_val);
        
        @(posedge start_tick);
        #1;

        if(Y == neg_val) begin
            $display("[%0t] El valor recibido es: %d ", $time, Y);
        end
        else begin
            $display("[%0t] No se recibió el valor correctamente", $time);
        end

        $display("[%0t] -----------------------------------------------------------------", $time);

        #100;
        $stop; 
		 
    end

endmodule