library verilog;
use verilog.vl_types.all;
entity PID is
    generic(
        ANCHO           : integer := 16;
        PERIODO         : integer := 32768;
        mK              : vl_logic_vector;
        Kb              : vl_logic_vector;
        KbmK            : vl_logic_vector;
        mKT_Ti          : vl_logic_vector;
        KT_Ti           : vl_logic_vector;
        KTdN_TdmsNT     : vl_logic_vector;
        mKTdN_TdmsNT    : vl_logic_vector;
        Td_TdmsNT       : vl_logic_vector
    );
    port(
        Uc              : in     vl_logic_vector;
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        clk_datos       : in     vl_logic;
        ini_fin         : in     vl_logic;
        bit_entrada     : in     vl_logic;
        PWM_pulse       : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ANCHO : constant is 1;
    attribute mti_svvh_generic_type of PERIODO : constant is 1;
    attribute mti_svvh_generic_type of mK : constant is 4;
    attribute mti_svvh_generic_type of Kb : constant is 4;
    attribute mti_svvh_generic_type of KbmK : constant is 4;
    attribute mti_svvh_generic_type of mKT_Ti : constant is 4;
    attribute mti_svvh_generic_type of KT_Ti : constant is 4;
    attribute mti_svvh_generic_type of KTdN_TdmsNT : constant is 4;
    attribute mti_svvh_generic_type of mKTdN_TdmsNT : constant is 4;
    attribute mti_svvh_generic_type of Td_TdmsNT : constant is 4;
end PID;
