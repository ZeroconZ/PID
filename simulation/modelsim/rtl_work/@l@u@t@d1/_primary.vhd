library verilog;
use verilog.vl_types.all;
entity LUTD1 is
    generic(
        Td_TdmsNT       : vl_logic_vector(15 downto 0) := (Hi0, Hi0, Hi0, Hi0, Hi0, Hi1, Hi0, Hi1, Hi0, Hi1, Hi0, Hi1, Hi0, Hi1, Hi0, Hi1)
    );
    port(
        lut_in          : in     vl_logic;
        lut_out         : out    vl_logic_vector(15 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Td_TdmsNT : constant is 2;
end LUTD1;
