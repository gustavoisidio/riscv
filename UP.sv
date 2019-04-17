module UP(input logic clock, reset);

logic [63:0] AluOut, outPC, outRegAlu;
logic [31:0] InstMemOut, Instr31_0; // 1 - Saida da Memoria de Instrucoes, 2 - Saida do registrador de Instrucoes para extensao de sinal e/ou shift
logic [64-1:0] bancoRegistradoresOut1, bancoRegistradoresOut2; // Saidas do Banco de Registradores
logic LoadIR, PCWrite, WriteRegBanco, LoadRegA, InstrType, DMemWR, LoadAluout; // Sinais de controle / Saida da Unidade de Controle
logic [4:0] Instr19_15, Instr24_20, Instr11_7; // Segmentacao da Instrucao / Saida do Registrador de Instrucoes
logic [6:0] Instr6_0;
logic [63:0] regAOut, regBOut; // Saida dos registradores A e B
logic [63:0] outExtend; // Saida da extensao de sinal
logic [63:0] outMux1, outMux2, outMux3; // Saida dos Mux
logic [63:0] DataMemOut, outMDR; // Saida da Memoria de Dados e do Registrador MDR
logic [2:0] AluSrcB, AluSrcA, AluFct, MemToReg;

// Instanciando PC
register PC (.clk(clock), .reset(reset), .regWrite(PCWrite), .DadoIn(AluOut), .DadoOut(outPC));

// Instanciando Memoria de Instrucoes
Memoria32 InstMem (.raddress(outPC[31:0]), .waddress(), .Clk(clock), .Datain(), .Dataout(InstMemOut), .Wr(1'b0));

// Instanciando Memoria de Dados
Memoria64 DataMem (.raddress(outRegAlu), .waddress(outRegAlu), .Clk(clock), .Datain(regBOut), .Dataout(DataMemOut), .Wr(DMemWR));

// Instanciando o Registrador de Instrucoes
Instr_Reg_RISC_V InstReg (.Clk(clock), .Reset(reset), .Load_ir(LoadIR), .Entrada(InstMemOut), .Instr19_15(Instr19_15), .Instr24_20(Instr24_20), .Instr11_7(Instr11_7), .Instr6_0(Instr6_0), .Instr31_0(Instr31_0));

// Instanciando a ULA
ula64 ULA (.A(outMux1), .B(outMux2), .Seletor(AluFct), .S(AluOut), .Overflow(), .Negativo(), .z(), .Igual(), .Maior(), .Menor());

// Instanciando o Banco de Registradores
bancoReg bancoRegistradores(.write(WriteRegBanco), .clock(clock), .reset(reset), .regreader1(Instr19_15), .regreader2(Instr24_20), .regwriteaddress(Instr11_7), .datain(outMux3), .dataout1(bancoRegistradoresOut1), .dataout2(bancoRegistradoresOut2));

// Instanciando Registrador A
register regA (.clk(clock), .reset(reset), .regWrite(LoadRegA), .DadoIn(bancoRegistradoresOut1), .DadoOut(regAOut));

// Instanciando Registrador B
register regB (.clk(clock), .reset(reset), .regWrite(LoadRegB), .DadoIn(bancoRegistradoresOut2), .DadoOut(regBOut));

// Instanciando a Extensao de sinal
signalExtend signalExt (.clock(clock), .reset(reset), .Instr31_0(Instr31_0), .InstrType(InstrType), .outExtend(outExtend));

// Instanciando Registrador da Alu
register regAlu (.clk(clock), .reset(reset), .regWrite(LoadAluout), .DadoIn(AluOut), .DadoOut(outRegAlu));

// Instanciando Mux 1
mux8to1 Mux1 ( .Out(outMux1),
               .Sel(AluSrcA),
               .In0(outPC), // Saida de PC
               .In1(regAOut), // Saida do Registrador A
               .In2(),
               .In3(),
               .In4(),
               .In5(),
               .In6(),
               .In7()
            );

// Instanciando Mux 2
mux8to1 Mux2 ( .Out(outMux2),
               .Sel(AluSrcB), 
               .In0(regBOut), // Saida do Registrador B
               .In1(64'd4), // 4, para PC + 4
               .In2(outExtend), // Extensao
               .In3(), // Shift
               .In4(),
               .In5(),
               .In6(),
               .In7()
             );

// Instanciando Mux 3
mux8to1 Mux3 ( .Out(outMux3),
               .Sel(MemToReg), 
               .In0(outMDR), // Saida do Registrador MDR 
               .In1(outRegAlu), // Saida da ALU
               .In2(), // 
               .In3(), 
               .In4(),
               .In5(),
               .In6(),
               .In7()
             );              

// Instanciando Registrador MDR
register MDR (.clk(clock), .reset(reset), .regWrite(LoadMDR), .DadoIn(DataMemOut), .DadoOut(outMDR));

// Instanciando a Unidade de Controle
UC uc ( .clock(clock),
        .reset(reset),
        .opcode(Instr6_0), // Opcode da instrucao
        .Instr31_0(), // Entrada [31:0] com a instrucao
        .LoadIR(LoadIR), // Seletor do Registrador de Instrucoes
        .PCWrite(PCWrite), // Seletor de escrita em PC
        .WriteRegBanco(WriteRegBanco), // Seletor do Banco de Registradores
        .LoadRegA(LoadRegA), // Seletor do Registrador A
        .LoadRegB(LoadRegB), // Seletor do Registrador B
        .InstrType(InstrType), // Seletor da Extensao de Sinal informando o tipo da instrucao
        .LoadMDR(LoadMDR), // Seletor do Registrador MDR
	.LoadAluout(LoadAluout),
        .MemToReg(MemToReg), // Seletor do Mux3
        .AluSrcA(AluSrcA), // Mux1
	.AluFct(AluFct), // Seletor de Funcao da ALU
        .AluSrcB(AluSrcB), // Mux2
        .DMemWR(DMemWR) // Seletor de da Memoria de Dados
      );

endmodule:UP