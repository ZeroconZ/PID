module LUTD1 #(
	
	parameter signed [15:0] Td_TdmsNT = 16'b0000010101010101
)(
	input lut_in,
	output reg signed[15:0] lut_out
);

	always @(*) begin
		case (lut_in)
			1'b0: lut_out = 16'd0;
			1'b1: lut_out = Td_TdmsNT;
			default: lut_out = 16'd0;
		endcase
	end

endmodule