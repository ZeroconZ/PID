library verilog;
use verilog.vl_types.all;
entity UCC is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        start_tick      : in     vl_logic;
        load_PISO       : out    vl_logic;
        new_val_delay   : out    vl_logic;
        shift_SO        : out    vl_logic;
        clear_acc       : out    vl_logic;
        enable_acc      : out    vl_logic;
        resta           : out    vl_logic;
        update_out      : out    vl_logic
    );
end UCC;
