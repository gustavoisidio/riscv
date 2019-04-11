module projeto(input logic clock, reset,
				output logic [6:0] estado,
				output logic [63:0] AluOut,
				output logic [31:0] outPC, InstMemOut, outIR,
				output logic IMemRead, LoadIR, PCWrite
              );


register PC (.clk(clock), .reset(reset), .regWrite(PCWrite), .DadoIn(AluOut), .DadoOut(outPC));

Memoria32 InstMem (.raddress(outPC), .waddress(), .Clk(clock), .Datain(), .Dataout(InstMemOut), .Wr(IMemRead));

Instr_Reg_RISC_V InstReg (.Clk(clock), .Reset(reset), .Load_ir(LoadIR), .Entrada(InstMemOut), .Instr19_15(), .Instr24_20(), .Instr11_7(), .Instr6_0(), .Instr31_0(outIR));

ula64 ULA (.A(outPC), .B(64'd4), .Seletor(3'b001), .S(AluOut));

controle UC (.clock(clock), .reset(reset), .estado(estado), .IMemRead(IMemRead), .LoadIR(LoadIR), .PCWrite(PCWrite));


endmodule:projeto

