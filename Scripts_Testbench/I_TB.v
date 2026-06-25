`timescale 1ns / 1ps

module I_TB;
    parameter ANCHO = 16;

    // VALORES LUT 
    parameter signed [ANCHO-1:0] mKT_Ti = -16'd819; 
    parameter signed [ANCHO-1:0] KT_Ti = 16'd819; 

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

    // CABLES INTERNOS AÑADIDOS Y CORREGIDOS
    wire start_tick;
    wire [ANCHO-1:0] Y;
    wire SO_Delay_Y;
    wire SO_Delay_Uc;

    wire load_PISO;
    wire shift_SO;
    wire clear_acc;
    wire enable_acc;
    wire resta; 
    wire update_out;

    wire [1:0] lut_inI = {SO_Delay_Uc, SO_Delay_Y};
    wire [ANCHO-1:0] I_out;
    wire [ANCHO-1:0] ACC_I_res;

    wire [ANCHO-1:0] Delay_Uc_out;
    wire [ANCHO-1:0] Delay_Y_out;
    wire [ANCHO-1:0] Delay_I_out;
    
    // CORRECCIÓN 1: Declaración de la señal I
    wire [ANCHO-1:0] I;

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

    Delay #(
        .ANCHO(ANCHO)
    ) Delay_Uc (
        .clk(clk),
        .reset(reset),
        .update(update_delays),
        .in_val(Uc),
        .out_val(Delay_Uc_out)
    );
    
    //PISO DEL DELAY DEL SETPOINT
    PISO #(
        .ANCHO(ANCHO)
    ) PISO_Delay_Uc (
        .clk(clk),
        .reset(reset),
        
        .load(load_PISO),
        .shift_in(shift_SO),

        .parallel_in(Delay_Uc_out),
        .serial_out(SO_Delay_Uc) 
    );
    
    //DELAY DEL FEEDBACK PARA LA LUT I
    Delay #(
        .ANCHO(ANCHO)
    ) Delay_Y (
        .clk(clk),
        .reset(reset),
        .update(update_delays),
        .in_val(Y),
        .out_val(Delay_Y_out)
    );
    
    //PISO DEL DELAY DEL FEEDBACK
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

    LUTI #(
        .mKT_Ti(mKT_Ti),
        .KT_Ti(KT_Ti)
    ) I_value (
        .lut_in(lut_inI),
        .lut_out(I_out)
    );

    ACC #(
        .ANCHO(ANCHO)
    ) ACC_I (
        .clk(clk),
        .reset(clear_acc),
        .enable(enable_acc),
        .sub(resta),
        .update_val(update_out),
        .val(I_out),
        .resultado(ACC_I_res)
    );
    
    Delay #(
        .ANCHO(ANCHO)
    ) Delay_I_block (
        .clk(clk),
        .reset(reset),
        .update(update_delays),
        .in_val(I),
        .out_val(Delay_I_out) // CORRECCIÓN 2: Homogeneización de mayúsculas
    );

    // CORRECCIÓN 3: Uso de las señales correctamente declaradas
    assign I = ACC_I_res + Delay_I_out;

    always #10 clk = ~clk;

    task test_I;
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
        Uc = 16'd16384;

        #100;
        reset = 0;
        #100;

        // ========================================================
        // CICLO 1: Carga de valores en los registros Delay
        // ========================================================
        $display("-----------------------------------------------------------------");
        Feedback = 16'd384;
        $display("[%0t] CICLO 1 - Envio de Feedback: %d", $time, Feedback);
        
        test_I(Feedback); 

        @(posedge start_tick); 
        if(Feedback == Y) $display("[%0t] [MONITOR] Rx OK: Y = %d", $time, Y);
        else $display("[%0t] [MONITOR] Hubo un problema en Rx", $time);

        @(posedge clear_acc)
        $display("\n--- INICIANDO BUCLE DA - CICLO 1 (Valores k-1 = 0) ---");
        for (j = 0; j < 16; j = j + 1) begin
            @(posedge clk); 
            #1; 
            $display("Iteracion %0d | bits {Uc_prev,Y_prev}: %b%b | Sale LUT: %d | val_interno: %d", 
                      j, SO_Delay_Uc, SO_Delay_Y, I_out, ACC_I.val_interno);
        end

        @(posedge update_out);
        @(posedge clk); 
        #1;             
        $display("[%0t] Fin Ciclo 1 -> ACC_I=%d | Delay_I_out(prev)=%d | Nuevo I(k)=%d", $time, ACC_I_res, Delay_I_out, I);
        
        // ========================================================
        // CICLO 2: Procesamiento Real de los datos inyectados
        // ========================================================
        #200;
        $display("\n-----------------------------------------------------------------");
        Feedback = 16'd384;
        $display("[%0t] CICLO 2 - Envio de Feedback: %d (Evaluando datos del ciclo 1)", $time, Feedback);
        
        test_I(Feedback); 
        
        @(posedge start_tick);
        @(posedge clear_acc)
        $display("\n--- INICIANDO BUCLE DA - CICLO 2 (Procesando Uc y Y) ---");
        for (j = 0; j < 16; j = j + 1) begin
            @(posedge clk); 
            #1; 
            $display("Iteracion %0d | bits {Uc_prev,Y_prev}: %b%b | Sale LUT: %d | val_interno: %d", 
                      j, SO_Delay_Uc, SO_Delay_Y, I_out, ACC_I.val_interno);
        end

        @(posedge update_out);
        @(posedge clk); 
        #1;             
        $display("[%0t] Fin Ciclo 2 -> ACC_I=%d | Delay_I_out(prev)=%d | Nuevo I(k)=%d", $time, ACC_I_res, Delay_I_out, I);

        #200;

        // ========================================================
        // CICLO 3: Procesamiento Real de los datos inyectados
        // ========================================================
        #200;
        $display("\n-----------------------------------------------------------------");
        Feedback = 16'd384;
        $display("[%0t] CICLO 3 - Envio de Feedback: %d (Evaluando datos del ciclo 3)", $time, Feedback);
        
        test_I(Feedback); 
        
        @(posedge start_tick);
        @(posedge clear_acc)
        $display("\n--- INICIANDO BUCLE DA - CICLO 2 (Procesando Uc y Y) ---");
        for (j = 0; j < 16; j = j + 1) begin
            @(posedge clk); 
            #1; 
            $display("Iteracion %0d | bits {Uc_prev,Y_prev}: %b%b | Sale LUT: %d | val_interno: %d", 
                      j, SO_Delay_Uc, SO_Delay_Y, I_out, ACC_I.val_interno);
        end

        @(posedge update_out);
        @(posedge clk); 
        #1;             
        $display("[%0t] Fin Ciclo 3 -> ACC_I=%d | Delay_I_out(prev)=%d | Nuevo I(k)=%d", $time, ACC_I_res, Delay_I_out, I);

        #200;

        // ========================================================
        // CICLO 4: Procesamiento Real de los datos inyectados
        // ========================================================
        #200;
        $display("\n-----------------------------------------------------------------");
        Feedback = 16'd384;
        $display("[%0t] CICLO 4 - Envio de Feedback: %d (Evaluando datos del ciclo 4)", $time, Feedback);
        
        test_I(Feedback); 
        
        @(posedge start_tick);
        @(posedge clear_acc)
        $display("\n--- INICIANDO BUCLE DA - CICLO 4 (Procesando Uc y Y) ---");
        for (j = 0; j < 16; j = j + 1) begin
            @(posedge clk); 
            #1; 
            $display("Iteracion %0d | bits {Uc_prev,Y_prev}: %b%b | Sale LUT: %d | val_interno: %d", 
                      j, SO_Delay_Uc, SO_Delay_Y, I_out, ACC_I.val_interno);
        end

        @(posedge update_out);
        @(posedge clk); 
        #1;             
        $display("[%0t] Fin Ciclo 4 -> ACC_I=%d | Delay_I_out(prev)=%d | Nuevo I(k)=%d", $time, ACC_I_res, Delay_I_out, I);

        #200;
        $stop;
    end

endmodule