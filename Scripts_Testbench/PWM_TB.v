`timescale 1ns / 1ps

module PWM_TB;

    parameter ANCHO = 16;

     //ENTRADAS
    reg clk;
    reg reset;
    reg start_pwm;
    reg full_speed;
    reg signed [ANCHO-1:0] entrada;

    //SALIDA
    wire PWM_out;

    //VALORES INTERNOS
    reg signed [ANCHO-1:0] val;
    integer ciclos_alto = 0;
    integer ciclos_totales = 0;
    real duty_cycle_detectado = 0.0;
    real duty_cycle_esperado = 0.0;

    PWM_gen #(
        .ANCHO(ANCHO)
    ) pwm_gen_t (
        .clk(clk),
        .reset(reset),

        .start_pwm(start_pwm),

        .full_speed(full_speed),

        .RESULTADO_PID(entrada),

        .PWM_out(PWM_out)
    );

    always #10 clk = ~clk;

    always @(posedge clk) begin
        if (!reset) begin
            if (pwm_gen_t.pwm_active && pwm_gen_t.tick_pwm) begin
                ciclos_totales <= ciclos_totales + 1;
                if (PWM_out == 1'b1) begin
                    ciclos_alto <= ciclos_alto + 1;
                end
            end
        end
    end

    task PWM_GEN_OP;
        input [ANCHO-1:0] val_in;

        begin
            @(posedge clk);
            #1;
            start_pwm <= 1;
            entrada <= val_in;

            @(posedge clk)
            #1
            start_pwm <= 0;
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        start_pwm = 0;

        #50;
        reset = 0;
        #30;

        //VALOR POSITIVO

        $display("[%0t] -----------------------------------------------------------------", $time);
        val = 16'h25A3;
        full_speed = 1;
        $display("[%0t] PRUEBA VALOR POSITIVO: %d", $time, val);
        
        PWM_GEN_OP(val);

        wait (pwm_gen_t.pwm_active == 1'b1);
        $display("[%0t] >> Módulo PWM activo. Esperando fin del tre 1 de pulsos...", $time);
        
        @(negedge pwm_gen_t.pwm_active);
        if (ciclos_totales > 0) begin
            duty_cycle_detectado = (ciclos_alto * 100.0) / ciclos_totales;
            $display(" PORCENTAJE DEL CICLO: %f %%", duty_cycle_detectado);
        end

        repeat(20) @(posedge clk);

        //VALOR NEGATIVO

        $display("\n[%0t] =======================================================", $time);
        
        ciclos_totales = 0;
        ciclos_alto = 0;

        val = 16'hEC78; 
        $display("[%0t] PRUEBA VALOR NEGATIVO: %d ", $time, $signed(val));
        
        PWM_GEN_OP(val);

        wait (pwm_gen_t.pwm_active == 1'b1);
        @(negedge pwm_gen_t.pwm_active);
        
        if (ciclos_totales > 0) begin
            $display("[%0t] Ciclos Totales: %d | Ticks en Alto: %d", $time, ciclos_totales, ciclos_alto);
            
            if (ciclos_totales == 32768 && ciclos_alto == 0)
                $display("[%0t] Funcionó bien", $time);
            else
                $display("[%0t] Oh no", $time);
        end
        $stop;
    end
endmodule