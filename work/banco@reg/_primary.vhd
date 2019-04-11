library verilog;
use verilog.vl_types.all;
entity bancoReg is
    port(
        write           : in     vl_logic;
        clock           : in     vl_logic;
        reset           : in     vl_logic;
        regreader1      : in     vl_logic_vector(4 downto 0);
        regreader2      : in     vl_logic_vector(4 downto 0);
        regwriteaddress : in     vl_logic_vector(4 downto 0);
        datain          : in     vl_logic_vector(63 downto 0);
        dataout1        : out    vl_logic_vector(63 downto 0);
        dataout2        : out    vl_logic_vector(63 downto 0)
    );
end bancoReg;
