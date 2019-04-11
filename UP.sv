module UP(input logic clock, reset);

logic [6:0] estado;
logic [63:0] AluOut, outPC;
logic [31:0] InstMemOut, outIR;
logic LoadIR, PCWrite;

logic [4:0] Instr19_15, Instr24_20, Instr11_7;
logic [6:0] Instr6_0;


register PC (.clk(clock), .reset(reset), .regWrite(PCWrite), .DadoIn(AluOut), .DadoOut(outPC));

Memoria32 InstMem (.raddress(outPC[31:0]), .waddress(), .Clk(clock), .Datain(), .Dataout(InstMemOut), .Wr(1'b0));

Instr_Reg_RISC_V InstReg (.Clk(clock), .Reset(reset), .Load_ir(LoadIR), .Entrada(InstMemOut), .Instr19_15(Instr19_15), .Instr24_20(Instr24_20), .Instr11_7(Instr11_7), .Instr6_0(Instr6_0), .Instr31_0(outIR));

ula64 ULA (.A(outPC), 
           .B(64'd4),
 	         .Seletor(3'b001),
	         .S(AluOut),
	         .Overflow(), 
           .Negativo(), 
           .z(), 
           .Igual(), 
           .Maior(), 
           .Menor()
);

UC uc (.clock(clock), .reset(reset), .estado(estado), .LoadIR(LoadIR), .PCWrite(PCWrite));


endmodule:UP