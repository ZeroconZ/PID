module PWM_gen #(
    parameter ANCHO = 16
)(
    input wire clk,
    input wire reset,
    input wire start_pwm,
    input wire full_speed,  
    input wire signed [ANCHO-1:0] RESULTADO_PID, 
    output reg PWM_out 
);

    localparam ANCHO_MAGNITUD = ANCHO - 1;
    localparam [ANCHO_MAGNITUD-1:0] MAX_COUNT = {ANCHO_MAGNITUD{1'b1}};

    wire [ANCHO_MAGNITUD-1:0] duty_cycle;
    
    assign duty_cycle = (RESULTADO_PID[ANCHO-1] == 1'b1) ? {ANCHO_MAGNITUD{1'b0}} : RESULTADO_PID[ANCHO_MAGNITUD-1:0];

    reg start_pwm_prev;
    wire start_edge;
    
    always @(posedge clk) begin
        if (reset) begin
            start_pwm_prev <= 1'b0;
        end else begin
            start_pwm_prev <= start_pwm;
        end
    end
    
    assign start_edge = start_pwm & ~start_pwm_prev;

    reg [6:0] prescaler;
    wire tick_pwm;

    always @(posedge clk) begin
        if (reset) begin
            prescaler <= 7'd0;
        end
        else if (full_speed) begin
            prescaler <= 7'd0;  
        end
        else if (prescaler == 7'd99) begin
            prescaler <= 7'd0;  
        end
        else begin
            prescaler <= prescaler + 1'b1;
        end
    end

    assign tick_pwm = full_speed ? 1'b1 : (prescaler == 7'd99);

    reg [ANCHO_MAGNITUD-1:0] pwm_count;
    reg pwm_active;

    always @(posedge clk) begin
        if (reset) begin
            pwm_count  <= {ANCHO_MAGNITUD{1'b0}};
            PWM_out    <= 1'b0;
            pwm_active <= 1'b0;
        end 
        else if (start_edge) begin
            pwm_active <= 1'b1;
            pwm_count  <= {ANCHO_MAGNITUD{1'b0}};
            PWM_out    <= (duty_cycle > {ANCHO_MAGNITUD{1'b0}}) ? 1'b1 : 1'b0;
        end
        else if (pwm_active && tick_pwm) begin
            if (pwm_count == MAX_COUNT) begin
                pwm_active <= 1'b0;
                pwm_count  <= {ANCHO_MAGNITUD{1'b0}};
                PWM_out    <= 1'b0;
            end
            else begin
                pwm_count <= pwm_count + 1'b1;
                
                if ((pwm_count + 1'b1) < duty_cycle) begin
                    PWM_out <= 1'b1;
                end
                else begin
                    PWM_out <= 1'b0;
                end
            end
        end
    end

endmodule