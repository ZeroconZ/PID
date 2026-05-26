module LUTD2 #(
	
	parameter signed [15:0] KTdN_TdmsNT = 16'b0011010101010101,
	parameter signed [15:0] mKTdN_TdmsNT = 16'b1011010101010101
)(
	input [1:0] lut_in,
	output reg signed[15:0] lut_out
);

	always @(*) begin
		case (lut_in)
			2'b00: lut_out = 16'd0;
			2'b01: lut_out = KTdN_TdmsNT;
			2'b10: lut_out = mKTdN_TdmsNT;
			2'b11: lut_out = 16'd0;
			default: lut_out = 16'd0;
		endcase
	end

endmodule