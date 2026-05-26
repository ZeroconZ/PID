module ACC_adder #(
    parameter ANCHO = 16
)(
    input wire clk,
    input wire reset,
    input wire update_out,

    input wire signed [ANCHO-1:0] ACC_P_res,
    input wire signed [ANCHO-1:0] ACC_I_res,
    input wire signed [ANCHO-1:0] ACC_D2_res,
    input wire signed [ANCHO-1:0] ACC_D1_res,

    output reg signed [ANCHO-1:0] RESULTADO_PID,
    output reg RESULTADO_ready
);

    reg update_out_delayed;  

    always @(posedge clk) begin
        if (reset) begin    
            RESULTADO_PID <= 0;
            RESULTADO_ready <= 1'b0;
            update_out_delayed <= 1'b0;
        end
        else begin
            update_out_delayed <= update_out;
            
            if (update_out_delayed) begin
                RESULTADO_PID <= ACC_P_res + ACC_I_res + ACC_D2_res + ACC_D1_res;
                RESULTADO_ready <= 1'b1;
            end
            else begin
                RESULTADO_ready <= 1'b0;
            end
        end
    end

endmodule