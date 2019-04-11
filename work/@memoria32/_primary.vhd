library verilog;
use verilog.vl_types.all;
entity Memoria32 is
    port(
        raddress        : in     vl_logic_vector(31 downto 0);
        waddress        : in     vl_logic_vector(31 downto 0);
        Clk             : in     vl_logic;
        Datain          : in     vl_logic_vector(31 downto 0);
        Dataout         : out    vl_logic_vector(31 downto 0);
        Wr              : in     vl_logic
    );
end Memoria32;
