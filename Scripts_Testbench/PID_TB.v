`timescale 1ns / 1ps

module system_TB;
    parameter ANCHO = 16;
    
    // ENTRADAS
    reg clk;
    reg reset;

    reg clk_datos;
    reg ini_fin;
    reg bit_entrada;
    
    parameter signed [ANCHO-1:0] Uc = 16'sd1000; 

    //PARAMETROS P
	parameter signed [ANCHO-1:0] mK = -16'd4096; 
    parameter signed [ANCHO-1:0] Kb = 16'd4096; 
    parameter signed [ANCHO-1:0] KbmK = 16'b0;

	//PARAMETROS I
	parameter signed [ANCHO-1:0] mKT_Ti = -16'sd410;
	parameter signed [ANCHO-1:0] KT_Ti =  16'sd410;

	//PARAMETROS D2
	parameter signed [ANCHO-1:0] KTdN_TdmsNT =  16'sd3413;
	parameter signed [ANCHO-1:0] mKTdN_TdmsNT =  -16'sd3413;

	//PARAMETROS D1
	parameter signed [ANCHO-1:0] Td_TdmsNT = 16'sd3413;

    wire PWM_pulse;

    // VARIABLES DE CONTROL LOCALES DEL TESTBENCH
    reg signed [ANCHO-1:0] Feedback;
    integer j; 

    // INSTANCIACIÓN DEL DUT
    PID #(
        .ANCHO(ANCHO),
        .Uc(Uc),

        .mK(mK),
        .Kb(Kb),
        .KbmK(KbmK),

        .mKT_Ti(mKT_Ti),
        .KT_Ti(KT_Ti),

        .KTdN_TdmsNT(KTdN_TdmsNT),
        .mKTdN_TdmsNT(mKTdN_TdmsNT),

        .Td_TdmsNT(Td_TdmsNT)
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
        $display("INICIO DE VERIFICACION DEL PID (TOP MODULE)");
        $display("=================================================================\n");

        for (j = 1; j <= 6; j = j + 1) begin
            // Introducimos un cambio dinámico (escalón) en el ciclo 4
            if (j == 1) begin
                Feedback = 16'd500; 
            end
            else if (j == 2) begin
                Feedback = 16'd700; 
            end
            else begin
                Feedback = 16'd100; 
            end

            
            $display("--- ENVIANDO MUESTRA %0d (Feedback = %0d) ---", j, Feedback);
            
            fork
                begin
                    send_spi_data(Feedback);
                end
                begin
                    @(posedge uut.start_tick); 
                end
            join

            if(Feedback == uut.Y) 
                $display("[%0t] [MONITOR SPI] Rx OK: Uc = %d Y = %d", $time, uut.Uc, uut.Y);
            else 
                $display("[%0t] [MONITOR SPI] ERROR: Corrupcion de datos en Rx", $time);
 
            // Esperar a que la UCC termine de calcular el algoritmo DA
            @(posedge uut.resultado_ready);
            @(posedge clk); 

            // MONITOR DE VARIABLES COMPLETO
            $display("Tiempo %0t:", $time);
            $display("   -> Accion P (Instantanea)       = %d", uut.ACC_P_res);
            $display("   -> Accion I (Integral Acumulada)= %d", uut.I);
            $display("   -> Accion D (Derivada Total)    = %d", uut.D); // AÑADIDO
            $display("---------------------------------------------------");

            $display("   -> RESULTADO PID (Suma Total)   = %d\n", uut.RESULTADO_PID);

            // Retardo entre muestras (simula la frecuencia de muestreo del sensor real)
            #5000; 
        end

        $display("[%0t] Procesamiento algoritmico finalizado.", $time);
        $display("Generando pulsos PWM continuos. Observe el Waveform...");
        
        // Tiempo extra para observar los ciclos del PWM generados con el último RESULTADO_PID
        #1000000; 
        
        $display("[%0t] Fin de la simulacion.", $time);
        $stop;
    end

endmodule