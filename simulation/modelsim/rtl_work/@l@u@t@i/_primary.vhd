library verilog;
use verilog.vl_types.all;
entity LUTI is
    generic(
        mKT_Ti          : vl_logic_vector(15 downto 0) := (Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi1, Hi0, Hi1, Hi0, Hi1, Hi1, Hi1, Hi0);
        KT_Ti           : vl_logic_vector(15 downto 0) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi1, Hi0, Hi0, Hi1, Hi0)
    );
    port(
        lut_in          : in     vl_logic_vector(1 downto 0);
        lut_out         : out    vl_logic_vector(15 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of mKT_Ti : constant is 2;
    attribute mti_svvh_generic_type of KT_Ti : constant is 2;
end LUTI;
