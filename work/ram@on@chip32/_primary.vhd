library verilog;
use verilog.vl_types.all;
entity ramOnChip32 is
    generic(
        ramSize         : vl_notype;
        ramWide         : vl_notype;
        ramAddrWide     : vl_notype
    );
    port(
        clk             : in     vl_logic;
        data            : in     vl_logic_vector;
        radd            : in     vl_logic_vector;
        wadd            : in     vl_logic_vector;
        wren            : in     vl_logic;
        q               : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of ramSize : constant is 5;
    attribute mti_svvh_generic_type of ramWide : constant is 5;
    attribute mti_svvh_generic_type of ramAddrWide : constant is 3;
end ramOnChip32;
