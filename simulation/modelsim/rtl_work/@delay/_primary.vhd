library verilog;
use verilog.vl_types.all;
entity Delay is
    generic(
        ANCHO           : integer := 16
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        update          : in     vl_logic;
        in_val          : in     vl_logic_vector;
        out_val         : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ANCHO : constant is 1;
end Delay;
