module PISO # (
    parameter ANCHO = 16
)(
    input wire clk,
    input wire reset,
    input wire load,
    input wire shift_in,
    input wire [ANCHO-1:0] parallel_in,

    output wire serial_out
);

    reg [ANCHO-1:0] shift_reg;

    always @(posedge clk) begin
        if (reset) begin
            shift_reg <= 0;
        end

        else if (load) begin
            shift_reg <= parallel_in;
        end

        else if (shift_in) begin
            shift_reg <= shift_reg >> 1;
        end
    end

    assign serial_out = shift_reg[0];

endmodule