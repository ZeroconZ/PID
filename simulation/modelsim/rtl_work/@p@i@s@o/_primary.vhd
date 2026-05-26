library verilog;
use verilog.vl_types.all;
entity PISO is
    generic(
        ANCHO           : integer := 16
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        load            : in     vl_logic;
        shift_in        : in     vl_logic;
        parallel_in     : in     vl_logic_vector;
        serial_out      : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ANCHO : constant is 1;
end PISO;
