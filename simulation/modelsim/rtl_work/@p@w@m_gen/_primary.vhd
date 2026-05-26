library verilog;
use verilog.vl_types.all;
entity PWM_gen is
    generic(
        ANCHO           : integer := 16
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        start_tick      : in     vl_logic;
        full_speed      : in     vl_logic;
        RESULTADO_PID   : in     vl_logic_vector;
        PWM_out         : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ANCHO : constant is 1;
end PWM_gen;
