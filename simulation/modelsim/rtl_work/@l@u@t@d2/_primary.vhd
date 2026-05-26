library verilog;
use verilog.vl_types.all;
entity LUTD2 is
    generic(
        KTdN_TdmsNT     : vl_logic_vector(15 downto 0) := (Hi0, Hi0, Hi1, Hi1, Hi0, Hi1, Hi0, Hi1, Hi0, Hi1, Hi0, Hi1, Hi0, Hi1, Hi0, Hi1);
        mKTdN_TdmsNT    : vl_logic_vector(15 downto 0) := (Hi1, Hi0, Hi1, Hi1, Hi0, Hi1, Hi0, Hi1, Hi0, Hi1, Hi0, Hi1, Hi0, Hi1, Hi0, Hi1)
    );
    port(
        lut_in          : in     vl_logic_vector(1 downto 0);
        lut_out         : out    vl_logic_vector(15 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of KTdN_TdmsNT : constant is 2;
    attribute mti_svvh_generic_type of mKTdN_TdmsNT : constant is 2;
end LUTD2;
