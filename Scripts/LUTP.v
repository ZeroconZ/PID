module LUTP #(
	parameter signed [15:0] mK = 16'b1001,
	parameter signed [15:0] Kb = 16'b0001,
	parameter signed [15:0] KbmK = 16'b0
)(
	input [1:0] lut_in,
	output reg signed[15:0] lut_out
);

	always @(*) begin
		case (lut_in)
			2'b00: lut_out = 16'd0;
			2'b01: lut_out = mK;
			2'b10: lut_out = Kb;
			2'b11: lut_out = KbmK;
			default: lut_out = 16'd0;
		endcase
	end

endmodule