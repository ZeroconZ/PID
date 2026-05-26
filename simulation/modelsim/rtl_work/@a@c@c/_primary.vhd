library verilog;
use verilog.vl_types.all;
entity ACC is
    generic(
        ANCHO           : integer := 16
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        enable          : in     vl_logic;
        sub             : in     vl_logic;
        update_val      : in     vl_logic;
        val             : in     vl_logic_vector;
        resultado       : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ANCHO : constant is 1;
end ACC;
