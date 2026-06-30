`timescale 1ns / 1ps

module PISO_TB;

    parameter ANCHO = 16;
    
    reg clk;
    reg reset;
    reg start_tick;
    reg [ANCHO-1:0] parallel_in;

    wire load_PISO;
    wire shift_SO;
    wire clear_acc;
    wire enable_acc;
    wire resta; 
    wire update_out;
    wire serial_out;

    integer i;
    reg [ANCHO-1:0] captured_data;

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

    PISO #(
        .ANCHO(ANCHO)
    ) uut_piso (
        .clk(clk),
        .reset(reset),

        .load(load_PISO),         
        .shift_in(shift_SO),      
        .parallel_in(parallel_in),

        .serial_out(serial_out)
    );

    // RELOJ SISTEMA (50 MHz)
    always #10 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        start_tick = 0;
        parallel_in = 0;
        captured_data = 0;

        #50;
        reset = 0;
        #50;

        $display("-----------------------------------------------------------------");

        parallel_in = 16'd35898; 
        $display("[%0t] Dato de entrada en paralelo: %d (%b)", $time, parallel_in, parallel_in);

        @(posedge clk);
        start_tick = 1;
        @(posedge clk);
        start_tick = 0;
        
        $display("[%0t] Pulso start_tick enviado", $time);

        @(negedge load_PISO); 
        captured_data[0] = serial_out; 
        $display("[%0t] UCC ejecuto LOAD. Bit [0] capturado: %b", $time, serial_out);

        i = 1;
        while (i < ANCHO) begin
            @(posedge clk); 
            
            if (shift_SO == 1'b1) begin
                @(negedge clk); 
                captured_data[i] = serial_out;
                $display("[%0t] UCC ejecuto SHIFT. Bit [%0d] %b", $time, i, serial_out);
                i = i + 1; 
            end
        end

        $display("-----------------------------------------------------------------");
        $display("[%0t] Valor reconstruido a partir de los bits serializados: %d (%b)", $time, captured_data, captured_data);
        if (captured_data == parallel_in) begin
            $display("[%0t] Los datos serializados concuerdan con los de entrada", $time);
        end else begin
            $display("[%0t] ERROR", $time);
        end
        $display("-----------------------------------------------------------------");

        #100;
        $stop; 
         
    end

endmodule