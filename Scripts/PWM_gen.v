module PWM_gen #(
    parameter ANCHO = 16
)(
    input wire clk,
    input wire reset,
    input wire start_tick,
    input wire full_speed,  // ← Add this
    input wire signed [ANCHO-1:0] RESULTADO_PID, 
    output reg PWM_out 
);

    wire [14:0] duty_cycle;
    assign duty_cycle = (RESULTADO_PID[15] == 1'b1) ? 15'd0 : RESULTADO_PID[14:0];

    reg start_tick_prev;
    wire start_edge;
    
    always @(posedge clk) begin
        start_tick_prev <= start_tick;
    end
    
    assign start_edge = start_tick & ~start_tick_prev;


    reg [6:0] prescaler;
    wire tick_pwm;

    always @(posedge clk) begin
        if (reset) begin
            prescaler <= 0;
        end
        else if (full_speed) begin
            prescaler <= 0;  
        end
        else if (prescaler == 7'd99) begin
            prescaler <= 0;  
        end
        else begin
            prescaler <= prescaler + 1;
        end
    end

    assign tick_pwm = full_speed ? 1'b1 : (prescaler == 7'd99);

    reg [14:0] pwm_count;
    reg pwm_active;

    always @(posedge clk) begin
        if (reset) begin
            pwm_count <= 0;
            PWM_out <= 1'b0;
            pwm_active <= 1'b0;
        end 
        else if (start_edge) begin
            pwm_active <= 1'b1;
            pwm_count <= 0;
            PWM_out <= (0 < duty_cycle) ? 1'b1 : 1'b0;
        end
        else if (pwm_active && tick_pwm) begin
            if (pwm_count == 15'd32767) begin
                pwm_active <= 1'b0;
                pwm_count <= 0;
                PWM_out <= 1'b0;
            end
            else begin
                pwm_count <= pwm_count + 1;
                
                if ((pwm_count + 1) < duty_cycle) begin
                    PWM_out <= 1'b1;
                end
                else begin
                    PWM_out <= 1'b0;
                end
            end
        end
    end

endmodule