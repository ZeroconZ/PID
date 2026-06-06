`timescale 1ns / 1ps

module ACC_TB;

    parameter ANCHO = 16;

    //ENTRADAS
    reg clk;
    reg reset;
    reg enable;
    reg sub;
    reg update_val;

    reg signed [ANCHO-1:0] val;

    //SALIDA
    wire signed [ANCHO-1:0] resultado;

    //VALORES INTERNOS
    reg signed [ANCHO-1:0] val_env_1;
    reg signed [ANCHO-1:0] val_env_2;
    reg hay_resta;

    ACC #(
        .ANCHO(ANCHO)
    ) acc_t (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .sub(sub),
        .update_val(update_val),

        .val(val),

        .resultado(resultado)
    );

    //RELOJ SISTEMA (50MHz)
    always #10 clk = ~clk;

    //SIMULACIÓN ENVIÓ DATOS Y CONTROL 
    task ACC_OP;
        input [ANCHO-1:0] val_1;
        input [ANCHO-1:0] val_2;
        input resta_status;
        integer i;

        reg [ANCHO-1:0] buffer[0:1];

        begin
            buffer[0] = val_1;
            buffer[1] = val_2;

            @(posedge clk);
            #1;
            enable <= 1;

            for (i = 0; i <= 1; i = i + 1) begin
                if(resta_status && (i == 1)) begin
                    sub <= 1;
                end 
                else begin
                    sub <= 0;
                end

                val <= buffer[i];    
                $display("[X%0t] Val = :%d", $time, acc_t.val_interno);
                @(posedge clk); 
                #1;
            end

            enable     <= 0;
            sub        <= 0;
            update_val <= 1;

            @(posedge clk);
            #1;
            update_val <= 0;
        end
    
    endtask

    initial begin
        clk = 0;
        reset = 1;
        enable = 0;
        sub = 0;
        update_val = 0;

        #50;
        reset = 0;
        #30;

        //UN CICLO SIN RESTA

        $display("[%0t] -----------------------------------------------------------------", $time);

        val_env_1 = 16'h25A3;
        val_env_2 = 0;
        hay_resta = 0;

        $display("[%0t] Envio de los valores: %d %d", $time, val_env_1, val_env_2);
        
        ACC_OP(val_env_1, val_env_2, hay_resta);

        if(resultado == 16'd4817) begin 
            $display("[%0t] El modulo divide bien", $time);
        end
        else begin
            $display("[%0t] Un pequeño percance: %d", $time, resultado);
        end

        //DOS CICLOS SIN RESTA
        $display("[%0t] -----------------------------------------------------------------", $time);
         
        @(posedge clk);
        #1;
        reset = 1; 
        #50;       

        @(posedge clk);
        #1;
        reset = 0; 
        #30;

        val_env_1 = 16'h25A3;
        val_env_2 = 16'h25A3;
        hay_resta = 0;

        $display("[%0t] Envio de los valores: %d %d", $time, val_env_1, val_env_2);
        
        ACC_OP(val_env_1, val_env_2, hay_resta);

        if(resultado == 16'd14452) begin 
            $display("[%0t] El modulo suma bien", $time);
        end
        else begin
            $display("[%0t] Un pequeño percance: %d", $time, resultado);
        end

        //DOS CICLOS CON RESTA
        $display("[%0t] -----------------------------------------------------------------", $time);
         
        @(posedge clk);
        #1;
        reset = 1; 
        #50;       

        @(posedge clk);
        #1;
        reset = 0; 
        #30;

        val_env_1 = 16'h25A3;
        val_env_2 = 16'h331;
        hay_resta = 1;

        $display("[%0t] Envio de los valores: %d %d", $time, val_env_1, val_env_2);
        
        ACC_OP(val_env_1, val_env_2, hay_resta);

        if(resultado == 16'd4000) begin 
            $display("[%0t] El modulo resta bien", $time);
        end
        else begin
            $display("[%0t] Un pequeño percance: %d", $time, resultado);
        end

        $stop;

    end

endmodule