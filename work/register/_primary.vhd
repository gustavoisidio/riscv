library verilog;
use verilog.vl_types.all;
entity \register\ is
    port(
        clk             : in     vl_logic;
        reset           : in     vl_logic;
        regWrite        : in     vl_logic;
        DadoIn          : in     vl_logic_vector(63 downto 0);
        DadoOut         : out    vl_logic_vector(63 downto 0)
    );
end \register\;
