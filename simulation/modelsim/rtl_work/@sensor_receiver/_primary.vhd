library verilog;
use verilog.vl_types.all;
entity Sensor_receiver is
    generic(
        ANCHO           : integer := 16
    );
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        clk_datos       : in     vl_logic;
        ini_fin         : in     vl_logic;
        bit_entrada     : in     vl_logic;
        Y               : out    vl_logic_vector;
        start_tick      : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ANCHO : constant is 1;
end Sensor_receiver;
