library verilog;
use verilog.vl_types.all;
entity Deslocamento is
    port(
        Shift           : in     vl_logic_vector(1 downto 0);
        Entrada         : in     vl_logic_vector(63 downto 0);
        N               : in     vl_logic_vector(5 downto 0);
        Saida           : out    vl_logic_vector(63 downto 0)
    );
end Deslocamento;
