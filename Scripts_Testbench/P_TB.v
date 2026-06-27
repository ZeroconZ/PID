`timescale 1ns / 1ps

module P_TB;
    parameter ANCHO = 16;

    // VALORES LUT 
    parameter signed [ANCHO-1:0] mK = -16'd4096; 
    parameter signed [ANCHO-1:0] Kb = 16'd4096; 
    parameter signed [ANCHO-1:0] KbmK = 16'b0;

    // VALORES DE PRUEBA
    reg signed [ANCHO-1:0] Uc;
    reg signed [ANCHO-1:0] Feedback; 
    // ENTRADAS GENERALES
    reg clk;
    reg reset;

    // ENTRADAS RECEPTOR
    reg clk_datos;
    reg ini_fin;
    reg bit_entrada;

    // CABLES INTERNOS AÑADIDOS Y CORREGIDOS
    wire start_tick;
    wire [ANCHO-1:0] Y;
    wire SO_Y;
    wire SO_Uc;

    wire load_PISO;
    wire shift_SO;
    wire clear_acc;
    wire enable_acc;
    wire resta; 
    wire update_out;

    wire [1:0] lut_inP;
    assign lut_inP = {SO_Uc, SO_Y};

    wire [ANCHO-1:0] P_out;
    wire [ANCHO-1:0] ACC_P_res;

    // MODULOS
    UCC #(
        .ANCHO(ANCHO)
    ) ucc_t (
        .clk(clk),
        .reset(reset),
        
        .start_tick(start_tick),

        .load_PISO(load_PISO),
        .shift_SO(shift_SO),
        
        .clear_acc(clear_acc),
        .enable_acc(enable_acc),
        .resta(resta),

        .update_out(update_out)
    );

    Sensor_receiver #(
        .ANCHO(ANCHO)
    ) sr_t (
        .clk(clk),
        .reset(reset),

        .clk_datos(clk_datos),
        .ini_fin(ini_fin),
        .bit_entrada(bit_entrada),
        
        .Y(Y),
        .start_tick(start_tick)
    );

    PISO #(
        .ANCHO(ANCHO)
    ) PISO_Y_t (
        .clk(clk),
        .reset(reset),
        
        .load(load_PISO),
        .shift_in(shift_SO),

        .parallel_in(Y),
        .serial_out(SO_Y) 
    );

    PISO #(
        .ANCHO(ANCHO)
    ) PISO_Uc_t (
        .clk(clk),
        .reset(reset),
        
        .load(load_PISO),
        .shift_in(shift_SO),

        .parallel_in(Uc),
        .serial_out(SO_Uc) 
    );

    LUTP #(
        .mK(mK),
        .Kb(Kb),
        .KbmK(KbmK)
    ) P_value_t (
        .lut_in(lut_inP),
        .lut_out(P_out)
    );

    ACC #(
        .ANCHO(ANCHO)
    ) ACC_P (
        .clk(clk),
        .reset(clear_acc),
        .enable(enable_acc),
        .sub(resta),
        .update_val(update_out),
        .val(P_out),
        .resultado(ACC_P_res)
    );

    always #10 clk = ~clk;

    task test_ACC_P;
        input [ANCHO-1:0] sent_data;
        integer i;
        begin
            // INICIO TRANSMISIÓN
            ini_fin = 1;
            #100;

            // ENVIO DEL ESP32 (MSB First)
            for (i = 15; i >= 0; i = i - 1) begin
                bit_entrada = sent_data[i]; 
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

    integer j;

    initial begin
        clk = 0;
        reset = 1;
        clk_datos = 0;
        ini_fin = 0;
        bit_entrada = 0;
        Uc = 16'd21845;

        #100;
        reset = 0;
        #100;

        $display("-----------------------------------------------------------------");
        Feedback = -16'd21846;
        $display("[%0t] Envio de un valor: %d", $time, Feedback);
        
        test_ACC_P(Feedback); 

        @(posedge start_tick); 
        if(Feedback == Y) $display("[%0t] [MONITOR] Rx OK: Y = %d", $time, Y);
        else $display("[%0t] [MONITOR] Hubo un problema papu en Rx", $time);

        @(posedge clear_acc)
        $display("\n--- INICIANDO BUCLE DA DE 16 CICLOS ---");
        // Bucle para espiar el procesamiento bit a bit
        for (j = 0; j < 16; j = j + 1) begin
            @(posedge clk); 
            #1; // Leer justo después del flanco para ver valores estables
            $display("Ciclo %0d | bits {Uc,Y}: %b%b | Sale LUT: %d | val_interno: %d", 
                      j, SO_Uc, SO_Y, P_out, ACC_P.val_interno);
        end
        $display("---------------------------------------\n");

        @(posedge update_out);
        @(posedge clk); // Espera al reloj que hace "resultado <= val_interno"
        #1;             // Margen de seguridad para lectura
        $display("[%0t] [MONITOR FINAL] Calculo completado -> ACC_P=%d Interno = %d", $time, ACC_P_res, ACC_P.val_interno);

        #100;
        $stop;
    end

endmodule