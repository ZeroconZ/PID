`timescale 1ns / 1ps

module tb_Final_adder;

    parameter ANCHO = 16;
    parameter signed [17:0] MAX_LIMIT = 18'd32767;
    parameter signed [17:0] MIN_LIMIT = -18'd32768;

    // ENTRADAS
    reg clk;
    reg reset;
    reg update;
    reg signed [ANCHO-1:0] P_in;
    reg signed [ANCHO-1:0] I_in;
    reg signed [ANCHO-1:0] D_in;

    // SALIDAS
    wire signed [ANCHO-1:0] U_out;
    wire out_ready;

    Final_adder #(
        .ANCHO(ANCHO),
        .MAX_LIMIT(MAX_LIMIT),
        .MIN_LIMIT(MIN_LIMIT)
    ) uut (
        .clk(clk),
        .reset(reset),
        .update(update),
        .P_in(P_in),
        .I_in(I_in),
        .D_in(D_in),
        .U_out(U_out),
        .out_ready(out_ready)
    );

    // RELOJ SISTEMA (50 MHz)
    always #10 clk = ~clk;

    // SECUENCIA DE ESTIMULOS
    initial begin
        clk = 0;
        reset = 1;
        update = 0;
        P_in = 0;
        I_in = 0;
        D_in = 0;

        #50;
        @(negedge clk);
        reset = 0;

        $display("-----------------------------------------------------------------");

        // PRUEBA 1: SUMA NORMAL
        @(negedge clk);
        update = 1;
        P_in = 16'd1000;
        I_in = 16'd2000;
        D_in = -16'd500;
        
        @(posedge clk);
        #1;
        
        if (U_out == 16'd2500 && out_ready == 1'b1) begin
            $display("[%0t] EXITO - Suma normal. U_out = %d", $time, U_out);
        end else begin
            $display("[%0t] ERROR - Suma normal. U_out = %d", $time, U_out);
        end

        $display("-----------------------------------------------------------------");

        // PRUEBA 2: SATURACION POSITIVA 
        @(negedge clk);
        update = 1;
        P_in = 16'd20000;
        I_in = 16'd15000;
        D_in = 16'd5000;
        
        @(posedge clk);
        #1;
        
        if (U_out == 16'd32767 && out_ready == 1'b1) begin
            $display("[%0t] Saturacion positiva. U_out = %d", $time, U_out);
        end else begin
            $display("[%0t] Saturacion positiva. U_out = %d", $time, U_out);
        end

        $display("-----------------------------------------------------------------");

        // PRUEBA 3: SATURACION NEGATIVA (UNDERFLOW)
        @(negedge clk);
        update = 1;
        P_in = -16'd20000;
        I_in = -16'd20000;
        D_in = 16'd5000;
        
        @(posedge clk);
        #1;
        
        if (U_out == -16'd32768 && out_ready == 1'b1) begin
            $display("[%0t] Saturacion negativa. U_out = %d", $time, U_out);
        end else begin
            $display("[%0t] Saturacion negativa. U_out = %d", $time, U_out);
        end

        $display("[%0t] -----------------------------------------------------------------", $time);

        // PRUEBA 4: UPDATE = 0 (RETENCION DE DATOS)
        @(negedge clk);
        update = 0;
        P_in = 16'd10;
        I_in = 16'd10;
        D_in = 16'd10;
        
        @(posedge clk);
        #1;
        
        if (U_out == -16'd32768 && out_ready == 1'b0) begin
            $display("[%0t] Retencion (update=0). U_out = %d", $time, U_out);
        end else begin
            $display("[%0t] Retencion (update=0). U_out = %d", $time, U_out);
        end

        $display("[%0t] -----------------------------------------------------------------", $time);

        #100;
        $stop;
    end

endmodule