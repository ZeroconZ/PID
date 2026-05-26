module PID (
	input wire u,
	input wire y,
	input wire clk, 
	input wire reset,
	input wire tick,
	
	output wire [15:0] P_value,
	output wire [15:0] I_value,
	output wire [15:0] D1_value,
	output wire [15:0] D2_value
);

	wire load_in;
	wire shift_piso;

	wire clear_ACC;
	wire enable_ACC;
	wire resta;
	wire update;

	wire [1:0] lut_in;
	assign lut_in = {u, y};
	
	wire [1:0] lutD2_in;
	assign lutD2_in = {y, delay_salida[0]};
	
	wire [1:0] delay_salida;
			
	UCC UCC_i (
		.clk(clk),
		.reset(reset),
		.start_tick(tick),
		
		.out(
	
	)
			
	Delay #(.ANCHO(2)) delay_entradas(
		.clk(clk),
		.reset(reset),
		.in_val(lut_in),
		.out_val(delay_salida)
		);
	
	LUTP P_action (
		.lut_in(lut_in),
		.lut_out(P_value)
		);

	LUTI I_action (
		.lut_in(delay_salida),
		.lut_out(I_value)
	);
	
	LUTD2 D2_action (
		.lut_in(lutD2_in),
		.lut_out(D2_value)
	);
	
	
endmodule