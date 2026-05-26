`timescale 1ns / 1ps

module tb_Sensor_receiver;

    parameter ANCHO = 16;
    
    //ENTRADAS
    reg clk;
    reg reset;
    reg clk_datos;
    reg ini_fin;
    reg bit_entrada;

    //SALIDAS
    wire signed [ANCHO-1:0] Y;
    wire start_tick;

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

    //RELOJ SISTEMA
    always #10 clk = ~clk;

    task send_spi_data;
        input [15:0] data_to_send; 
        integer i;
        begin
            //INICIO TRANSMISIÓN
            ini_fin = 1;
            #100;

            //ENVIO DEL ESP32
            for (i = 15; i >= 0; i = i - 1) begin
                bit_entrada = data_to_send[i];
                #100;          
                clk_datos = 1; 
                #200;          
                clk_datos = 0; 
                #100;          
            end

            //FIN TRANSMISIÓN
            #100;
            ini_fin = 0;
            
            #200; 
        end
    endtask

    //PRUEBAS
    initial begin
        clk = 0;
        reset = 1;
        clk_datos = 0;
        ini_fin = 0;
        bit_entrada = 0;

        //LIMPIEZA DEL CONTROLADOR
        #50;
        reset = 0;
        #50;

        $display("[%0t] -----------------------------------------------------------------", $time)

        //PRUEBA VALOR POSITIVO
        pos_val =  16'h25A3;
        $display("[%0t] Envio de un valor positivo", $time);
        send_spi_data(pos_val);
        
        @(posedge start_tick);
        #1;

        if(Y == pos_val) begin
            $display("[%0t] Todo ha salido a pedir de Mil House", $time)
        end
        else begin
            $display("[%0t] Hubo un percance", $time)
        end

        $display("[%0t] -----------------------------------------------------------------", $time)

        //PRUEBA VALOR NEGATIVO
        #500;

        neg_val =  16'hE000;
        $display("[%0t] Envio de un valor positivo", $time);
        send_spi_data(neg_val);
        
        @(posedge start_tick);
        #1;

        if(Y == neg_val) begin
            $display("[%0t] Todo ha salido a pedir de Mil House", $time)
        end
        else begin
            $display("[%0t] Hubo un percance", $time)
        end

        $display("[%0t] -----------------------------------------------------------------", $time)

        //PRUEBA METAESTABILIDAD
        #500;

        @(posedge clk);

        //SE FUERZAN DATOS INDETERMINADOS
        bit_entrada = 1'bx; 
        clk_datos   = 1'bx;
        ini_fin     = 1;

        @(posedge clk);
        $display("[%0t] [MONITOR CDC] FF1=%b, FF2=%b", $time, uut.sync_clk_datos_1, uut.sync_clk_datos_2);

        //VUELTA A CONDICIONES NORMALES
        #5; 
        bit_entrada = 1;
        clk_datos   = 0;

        repeat (3) @(posedge clk); //ESPERA HASTA QUE LOS FLIP-FLOPS LIMPIAN EL VALOR INDETERMINADO

        $display("[%0t] [MONITOR CDC POST-METAESTABILIDAD] FF1=%b, FF2=%b", $time, uut.sync_clk_datos_1, uut.sync_clk_datos_2);

        if (uut.sync_clk_datos_2 !== 1'bx) begin
        $display("[%0t] [TEST PASSED] Se limpió la metaestabilidad", $time);
        end else begin
            $display("[%0t] [TEST FAILED] La metaestabilidad se propagó", $time);
        end
    end

endmodule