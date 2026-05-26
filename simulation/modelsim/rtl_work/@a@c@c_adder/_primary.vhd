library verilog;
use verilog.vl_types.all;
entity ACC_adder is
    generic(
        ANCHO           : integer := 16
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        update_out      : in     vl_logic;
        ACC_P_res       : in     vl_logic_vector;
        ACC_I_res       : in     vl_logic_vector;
        ACC_D2_res      : in     vl_logic_vector;
        ACC_D1_res      : in     vl_logic_vector;
        RESULTADO_PID   : out    vl_logic_vector;
        RESULTADO_ready : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ANCHO : constant is 1;
end ACC_adder;
