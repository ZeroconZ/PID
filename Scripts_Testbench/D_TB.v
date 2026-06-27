`timescale 1ns / 1ps

module D_TB; // Cambiado el nombre para mayor claridad
    parameter ANCHO = 16;

    // PARAMETROS D2
    parameter signed [ANCHO-1:0] KTdN_TdmsNT =  16'd3416;
    parameter signed [ANCHO-1:0] mKTdN_TdmsNT = -16'd3416;

    // PARAMETROS D1
    parameter signed [ANCHO-1:0] Td_TdmsNT = 16'd3416;

    // VALORES DE PRUEBA
    reg signed [ANCHO-1:0] Uc;
    reg signed [ANCHO-1:0] Feedback; 
    
    reg update_delays;
    
    // ENTRADAS GENERALES
    reg clk;
    reg reset;

    // ENTRADAS RECEPTOR
    reg clk_datos;
    reg ini_fin;
    reg bit_entrada;

    // CABLES INTERNOS
    wire start_tick;
    wire [ANCHO-1:0] Y;
    
    wire load_PISO;
    wire shift_SO;
    wire clear_acc;
    wire enable_acc;
    wire resta; 
    wire update_out;

    // ==========================================
    // CORRECCIÓN 1: Declaración de TODAS las señales D
    // ==========================================
    wire SO_Y;           // Salida serie de Y actual
    wire SO_Delay_Y;     // Salida serie de Y anterior
    
    wire [1:0] lut_inD2;
    wire [ANCHO-1:0] D2_out;
    wire [ANCHO-1:0] ACC_D2_res;

    wire [ANCHO-1:0] D;
    wire [ANCHO-1:0] Delay_D_out;
    wire SO_D;
    wire [ANCHO-1:0] D1_out;
    wire [ANCHO-1:0] ACC_D1_res;
    
    wire [ANCHO-1:0] Delay_Y_out;

    // Mapeo de la entrada a la LUT D2: y(k)[j] en bit 1, y(k-1)[j] en bit 0
    assign lut_inD2 = {SO_Y, SO_Delay_Y};

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

    always @(posedge clk) begin
        if (reset) begin
            update_delays <= 1'b0;
        end else begin
            update_delays <= update_out;
        end
    end

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
    
    // ==========================================
    // CORRECCIÓN 2: PISO para serializar el valor Y actual (y_k)
    // ==========================================
    PISO #(
        .ANCHO(ANCHO)
    ) PISO_Y (
        .clk(clk),
        .reset(reset),
        .load(load_PISO),
        .shift_in(shift_SO),
        .parallel_in(Y),
        .serial_out(SO_Y) 
    );

    Delay #(
        .ANCHO(ANCHO)
    ) Delay_Y_block (
        .clk(clk),
        .reset(reset),
        .update(update_delays),
        .in_val(Y),
        .out_val(Delay_Y_out)
    );
    
    // PISO para el Y anterior (y_k-1)
    PISO #(
        .ANCHO(ANCHO)
    ) PISO_Delay_Y (
        .clk(clk),
        .reset(reset),
        .load(load_PISO),
        .shift_in(shift_SO),
        .parallel_in(Delay_Y_out),
        .serial_out(SO_Delay_Y) 
    );

    LUTD2 #(
        .KTdN_TdmsNT(KTdN_TdmsNT),
        .mKTdN_TdmsNT(mKTdN_TdmsNT)
    ) D2_value (
        .lut_in(lut_inD2),
        .lut_out(D2_out)
    );

    ACC #(
        .ANCHO(ANCHO)
    ) ACC_D2 (
        .clk(clk),
        .reset(clear_acc),
        .enable(enable_acc),
        .sub(resta),
        .update_val(update_out),
        .val(D2_out),
        .resultado(ACC_D2_res)
    );

    // ==========================================
    // RUTA D1 (Término recursivo)
    // ==========================================
    Delay #(
        .ANCHO(ANCHO)
    ) Delay_D1_block (
        .clk(clk),
        .reset(reset),
        .update(update_delays),
        .in_val(D),
        .out_val(Delay_D_out)
    );

    PISO #(
        .ANCHO(ANCHO)
    ) PISO_D1 (
        .clk(clk),
        .reset(reset),
        .load(load_PISO),
        .shift_in(shift_SO),
        .parallel_in(Delay_D_out),
        .serial_out(SO_D) 
    );  

    LUTD1 #(
        .Td_TdmsNT(Td_TdmsNT)
    ) D1_value (
        .lut_in(SO_D),
        .lut_out(D1_out)
    );

    ACC #(
        .ANCHO(ANCHO)
    ) ACC_D1 (
        .clk(clk),
        .reset(clear_acc),
        .enable(enable_acc),
        .sub(resta),
        .update_val(update_out),
        .val(D1_out),
        .resultado(ACC_D1_res)
    );

    // SUMADOR FINAL DERIVATIVO
    assign D = ACC_D2_res + ACC_D1_res;

    always #10 clk = ~clk;

    task test_sensor;
        input [ANCHO-1:0] sent_data;
        integer i;
        begin
            ini_fin = 1;
            #100;
            for (i = 15; i >= 0; i = i - 1) begin
                bit_entrada = sent_data[i]; 
                #100;          
                clk_datos = 1; 
                #200;          
                clk_datos = 0; 
                #100;          
            end
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
        
        #100;
        reset = 0;
        #100;

        // ========================================================
        // CICLO 1: Primer valor 
        // ========================================================
        $display("-----------------------------------------------------------------");
        Feedback = 16'd1000;
        $display("[%0t] CICLO 1 - Envio de Feedback: %d", $time, Feedback);
        
        test_sensor(Feedback); 

        @(posedge update_out);
        @(posedge clk); 
        #1;             
        $display("[%0t] Fin Ciclo 1 -> ACC_D2=%d | ACC_D1=%d | D(k) Total=%d", $time, ACC_D2_res, ACC_D1_res, D);
        
        // ========================================================
        // CICLO 2
        // ========================================================
        #200;
        $display("\n-----------------------------------------------------------------");
        Feedback = 16'd2000;
        $display("[%0t] CICLO 2 - Envio de Feedback: %d (Evaluando Y_act = Y_prev)", $time, Feedback);
        
        test_sensor(Feedback); 

        @(posedge update_out);
        @(posedge clk); 
        #1;             
        $display("[%0t] Fin Ciclo 2 -> ACC_D2=%d | ACC_D1=%d | D(k) Total=%d", $time, ACC_D2_res, ACC_D1_res, D);

        // ========================================================
        // CICLO 3
        // ========================================================
        $display("-----------------------------------------------------------------");
        Feedback = 16'd500;
        $display("[%0t] CICLO 1 - Envio de Feedback: %d", $time, Feedback);
        
        test_sensor(Feedback); 

        @(posedge update_out);
        @(posedge clk); 
        #1;             
        $display("[%0t] Fin Ciclo 1 -> ACC_D2=%d | ACC_D1=%d | D(k) Total=%d", $time, ACC_D2_res, ACC_D1_res, D);
        

        #200;
        $stop;
    end

endmodule