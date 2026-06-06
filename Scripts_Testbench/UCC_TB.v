`timescale 1ns / 1ps

module UCC_TB;

    parameter ANCHO = 16;

    //ENTRADAS
    reg clk;
    reg reset;
    reg start_tick;

    //VARIABLES DE CONTROL EN EL TB

    //SALIDAS
    wire load_PISO;
    wire shift_SO;
    wire clear_acc;
    wire enable_acc;
    wire resta;
    wire update_out;

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

    //SEÑAL RELOJ (50MHz)
    always #10 clk = ~clk;

    task test_UCC;
        begin
            //INICIO CONTROL
            @(posedge clk)
            start_tick = 1;
            
            @(posedge clk)
            start_tick = 0;
        end
    endtask

    initial begin 
        clk = 0;
        reset = 1;
        start_tick = 0;

        //LIMPIEZA DEL MODULO
        #50;
        reset = 0;
        #30;

        $display("[%0t] -----------------------------------------------------------------", $time);

        test_UCC();

        //PRUEBA FUNCIONAMIENTO
        @(posedge update_out);
        #40;
        $stop;
    end

endmodule