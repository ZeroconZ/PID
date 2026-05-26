module LUTI #(
	
	parameter signed [15:0] mKT_Ti = 16'b1111111110101110,
	parameter signed [15:0] KT_Ti =  16'b0000000001010010
)(
	input [1:0] lut_in,
	output reg signed[15:0] lut_out
);

	always @(*) begin
		case (lut_in)
			2'b00: lut_out = 16'd0;
			2'b01: lut_out = mKT_Ti;
			2'b10: lut_out = KT_Ti;
			2'b11: lut_out = 16'd0;
			default: lut_out = 16'd0;
		endcase
	end

endmodule