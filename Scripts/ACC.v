module ACC #(
	parameter ANCHO = 16
)(
	input wire clk,
	input wire reset,
	input wire enable,
	input wire sub,
	input wire update_val,

	input wire signed[ANCHO-1:0] val,
	output reg signed[ANCHO-1:0] resultado
);

	reg signed [ANCHO-1:0] val_interno;
	
	always @(posedge clk) begin
		if (reset) begin
			val_interno <= 0;
		end
		
		else if (enable) begin
			if (sub) begin
				val_interno <= (val_interno >>> 1) - val;
			end
			
			else begin
				val_interno <= (val_interno >>> 1) + val;
			end
		end
	end
	
	always @(posedge clk) begin
		if (reset) begin 
			resultado <= 0;
		end
		else if (update_val) begin
			resultado <= val_interno ;
		end
	end

endmodule