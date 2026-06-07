module PID #(
	parameter ANCHO = 12,
	parameter PERIODO = 2048,

	//PARAMETROS P
	parameter signed [ANCHO-1:0] mK = 16'b100100000000,
	parameter signed [ANCHO-1:0] Kb = 16'b000100000000,
	parameter signed [ANCHO-1:0] KbmK = 16'b0,

	//PARAMETROS I
	parameter signed [ANCHO-1:0] mKT_Ti = 16'b100001010010,
	parameter signed [ANCHO-1:0] KT_Ti =  16'b000001010010,

	//PARAMETROS D2
	parameter signed [ANCHO-1:0] KTdN_TdmsNT =  16'b010101010101,
	parameter signed [ANCHO-1:0] mKTdN_TdmsNT =  16'b110101010101,

	//PARAMETROS D1
	parameter signed [ANCHO-1:0] Td_TdmsNT = 16'b010101010101
)(
	input wire [ANCHO-1:0] Uc, //Señal set point

	input wire clk, 
	input wire reset,

	input wire clk_datos,
	input wire ini_fin,
	input wire bit_entrada,

	output wire PWM_pulse
);
	//Cable con la entrada de datos
	wire [ANCHO-1:0] Y;

	wire [ANCHO-1:0] RESULTADO_PID;

	wire [ANCHO-1:0] Delay_I_Out;
	wire [ANCHO-1:0] I;
	wire [ANCHO-1:0] D;

	//CONTROL ACC
	wire clear_acc;
	wire enable_acc;
	wire resta;
	wire update_out;
	wire start_tick;

	//RESULTADO ACC
	wire [ANCHO-1:0] ACC_P_res;
	wire [ANCHO-1:0] ACC_I_res;
	wire [ANCHO-1:0] ACC_D2_res;
	wire [ANCHO-1:0] ACC_D1_res;

	//IO PISOs
	wire load_PISO;
	wire shift_SO;

	wire SO_Uc;
	wire SO_Y;

	wire SO_Delay_Uc;
	wire SO_Delay_Y;
	wire SO_D;

	wire [ANCHO-1:0] Delay_Uc_out;
	wire [ANCHO-1:0] Delay_Y_out;

	//IO LUTs
	wire [1:0] lut_inP = {SO_Uc, SO_Y};
	wire [1:0] lut_inI = {SO_Delay_Uc, SO_Delay_Y};
	wire [1:0] lut_inD2 = {SO_Y, SO_Delay_Y};

	wire [ANCHO-1:0] I_out;
	wire [ANCHO-1:0] P_out;
	wire [ANCHO-1:0] D2_out;
	wire [ANCHO-1:0] D1_out;

	
	//MODULO DE CONTROL CENTRAL
	UCC UCCi (
		.clk(clk),
		.reset(reset),
		.start_tick(start_tick),

		.load_PISO(load_PISO),
		.shift_SO(shift_SO),

		.clear_acc(clear_acc),
		.enable_acc(enable_acc),
		.resta(resta),
		.update_out(update_out)
	);

	Sensor_receiver #(
		.ANCHO(ANCHO)
	) Recepcion_feedback (
		.clk(clk), 
		.reset(reset),

		.clk_datos(clk_datos),
		.ini_fin(ini_fin),
		.bit_entrada(bit_entrada),

		.Y(Y),
		.start_tick(start_tick)
	);

	//PISO DEL SETPOINT
	PISO #(
		.ANCHO(ANCHO)
	) PISO_Uc (
		.clk(clk),
		.reset(reset),
		
		.load(load_PISO),
		.shift_in(shift_SO),

		.parallel_in(Uc),
		.serial_out(SO_Uc) 
	);
	
	//PISO DEL FEEDBACK
	PISO #(
		.ANCHO(ANCHO)
	) PISO_Y (
		.clk(clk),
		.reset(reset),
		
		.load(load_PISO),
		.shift_in(shift_SO),

		.parallel_in(Y),
		.serial_out(SO_Y) 
	);
	
	//DELAY DEL SETPOINT PARA LA LUT I
	Delay #(
		.ANCHO(ANCHO)
	) Delay_Uc (
		.clk(clk),
		.reset(reset),
		.update(update_out),
		.in_val(Uc),
		.out_val(Delay_Uc_out)
	);
	
	//PISO DEL DELAY DEL SETPOINT
	PISO #(
		.ANCHO(ANCHO)
	) PISO_Delay_Uc (
		.clk(clk),
		.reset(reset),
		
		.load(load_PISO),
		.shift_in(shift_SO),

		.parallel_in(Delay_Uc_out),
		.serial_out(SO_Delay_Uc) 
	);
	
	//DELAY DEL FEEDBACK PARA LA LUT I
	Delay #(
		.ANCHO(ANCHO)
	) Delay_Y (
		.clk(clk),
		.reset(reset),
		.update(update_out),
		.in_val(Y),
		.out_val(Delay_Y_out)
	);
	
	//PISO DEL DELAY DEL FEEDBACK
	PISO #(
		.ANCHO(ANCHO)
	) PISO_Delay_Y (
		.clk(clk),
		.reset(reset),
		
		.load(load_PISO),
		.shift_in(shift_SO),

		.parallel_in(Delay_Y_out),
		.serial_out(SO_Delay_Y) 
	);

	//ACCION PROPORCIONAL
	LUTP #(
		.mK(mK),
		.Kb(Kb),
		.KbmK(KbmK)
	) P_value (
		.lut_in(lut_inP),
		.lut_out(P_out)
	);

	ACC #(
		.ANCHO(ANCHO)
	) ACC_P (
		.clk(clk),
		.reset(reset),
		.enable(enable_acc),
		.sub(resta),
		.update_val(update_out),
		.val(P_out),
		.resultado(ACC_P_res)
	);

	//ACCION INTEGRAL
	LUTI #(
		.mKT_Ti(mKT_Ti),
		.KT_Ti(KT_Ti)
	) I_value (
		.lut_in(lut_inI),
		.lut_out(I_out)
	);
	
	ACC #(
		.ANCHO(ANCHO)
	) ACC_I (
		.clk(clk),
		.reset(reset),
		.enable(enable_acc),
		.sub(resta),
		.update_val(update_out),
		.val(I_out),
		.resultado(ACC_I_res)
	);
	
	Delay #(
		.ANCHO(ANCHO)
	) Delay_I (
		.clk(clk),
		.reset(reset),
		.update(update_out),
		.in_val(ACC_I_res),
		.out_val(Delay_I_Out)
	);
	
	assign I = ACC_I_res + Delay_I_Out;

	//ACCION DERIVATIVA
	LUTD2 #(
		.KTdN_TdmsNT(KTdN_TdmsNT),
		.mKTdN_TdmsNT(mKTdN_TdmsNT)
	) D2_value (
		.lut_in(lut_inD2),
		.lut_out(D2_out)
	);

	ACC #(
		.ANCHO(ANCHO)
	) ACC_D2 (
		.clk(clk),
		.reset(reset),
		.enable(enable_acc),
		.sub(resta),
		.update_val(update_out),
		.val(D2_out),
		.resultado(ACC_D2_res)
	);

	PISO #(
		.ANCHO(ANCHO)
	) PISO_D1 (
		.clk(clk),
		.reset(reset),
		
		.load(load_PISO),
		.shift_in(shift_SO),

		.parallel_in(D), //AÑADIR ENTRADA
		.serial_out(SO_D) //AÑADIR SALIDA
 	);	

	LUTD1 #(
		.Td_TdmsNT(Td_TdmsNT)
	) D1_value (
		.lut_in(SO_ACC_D2),
		.lut_out(D1_out)
	);

	ACC #(
		.ANCHO(ANCHO)
	) ACC_D1 (
		.clk(clk),
		.reset(reset),
		.enable(enable_acc),
		.sub(resta),
		.update_val(update_out),
		.val(D1_out),
		.resultado(ACC_D1_res)
	);

	assign D = ACC_D2_res + ACC_D1_res;

	ACC_adder #(
    .ANCHO(ANCHO)
	) ACC_adder (
		.clk(clk),
		.reset(reset),
		.update_out(update_out),     
		
		.ACC_P_res(ACC_P_res),
		.ACC_I_res(I),
		.ACC_D2_res(ACC_D2_res),
		.ACC_D1_res(ACC_D1_res),
		
		.RESULTADO_PID(RESULTADO_PID),
		.RESULTADO_ready(resultado_ready)
	);

	PWM_gen #(
		.ANCHO(ANCHO)
	) PWM_gen (
		.clk(clk),
		.reset(reset),
		.start_pwm(resultado_ready),  
		.full_speed(1'b1),
		.RESULTADO_PID(RESULTADO_PID),
		.PWM_out(PWM_pulse)
	);

endmodule