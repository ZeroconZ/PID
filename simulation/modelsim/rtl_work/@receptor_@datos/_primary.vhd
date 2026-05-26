library verilog;
use verilog.vl_types.all;
entity Receptor_Datos is
    generic(
        ANCHO           : integer := 16
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ANCHO : constant is 1;
end Receptor_Datos;
