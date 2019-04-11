library verilog;
use verilog.vl_types.all;
entity UC is
    port(
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        estado          : out    vl_logic_vector(6 downto 0);
        LoadIR          : out    vl_logic;
        PCWrite         : out    vl_logic
    );
end UC;
