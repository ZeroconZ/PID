`timescale 1ns / 1ps

module PWM_gen #(
    parameter ANCHO = 16,
    parameter [14:0] MAX_COUNT = 15'd32767 
)(
    input  wire clk,
    input  wire reset,
    input  wire data_ready,    
    input  wire full_speed,  
    input  wire signed [ANCHO-1:0] RESULTADO_PID, 
    output reg  PWM_out 
);

    wire [14:0] duty_cycle_next;
    assign duty_cycle_next = (RESULTADO_PID[15] == 1'b1) ? 15'd0 : RESULTADO_PID[14:0];

    // 2. Registro de Retención (Shadow Register) para evitar glitches
    reg [14:0] duty_cycle_latched;

    always @(posedge clk) begin
        if (reset) begin
            duty_cycle_latched <= 15'd0;
        end 
        else if (data_ready) begin 
            duty_cycle_latched <= duty_cycle_next;
        end
    end

    reg [6:0] prescaler;
    wire tick_pwm;

    always @(posedge clk) begin
        if (reset) begin
            prescaler <= 7'd0;
        end
        else if (full_speed || prescaler == 7'd99) begin
            prescaler <= 7'd0;  
        end
        else begin
            prescaler <= prescaler + 1'b1;
        end
    end

    assign tick_pwm = full_speed ? 1'b1 : (prescaler == 7'd99);

    reg [14:0] pwm_count;

    always @(posedge clk) begin
        if (reset) begin
            pwm_count <= 15'd0;
            PWM_out   <= 1'b0;
        end 
        else if (tick_pwm) begin
            if (pwm_count >= MAX_COUNT) begin
                pwm_count <= 15'd0;
            end
            else begin
                pwm_count <= pwm_count + 1'b1;
            end
            
            if (duty_cycle_latched == 15'd0) begin
                PWM_out <= 1'b0; 
            end
            else if (pwm_count < duty_cycle_latched) begin
                PWM_out <= 1'b1; 
            end
            else begin
                PWM_out <= 1'b0; 
            end
        end
    end

endmodule