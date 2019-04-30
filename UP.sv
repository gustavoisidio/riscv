module UP(input logic clock, reset);

logic [63:0] AluOut, outPC, outRegAlu;
logic [31:0] InstMemOut, Instr31_0; // 1 - Saida da Memoria de Instrucoes, 2 - Saida do registrador de Instrucoes para extensao de sinal / extensao para PC              
logic [64-1:0] bancoRegistradoresOut1, bancoRegistradoresOut2; // Saidas do Banco de Registradores
logic LoadIR, PCWrite, WriteRegBanco, LoadRegA, DMemWR, LoadAluout, writeEPC; // Sinais de controle / Saida da Unidade de Controle
logic [4:0] Instr19_15, Instr24_20, Instr11_7; // Segmentacao da Instrucao / Saida do Registrador de Instrucoes
logic [6:0] Instr6_0;
logic [63:0] regAOut, regBOut; // Saida dos registradores A e B
logic [63:0] outExtend; // Saida da extensao de sinal
logic [63:0] outMux1, outMux2, outMux3, outMux5; // Saida dos Mux
logic [31:0] outMux6; // Saida dos Mux
logic [4:0] outMux4; // Saida dos Mux
logic [63:0] DataMemOut, outMDR, outEPC; // Saida da Memoria de Dados, do Registrador MDR e do EPC
logic [63:0] outExtendToPC; 
logic [2:0] AluSrcB, // Mu2
            AluSrcA, // Mu1 
            AluFct, // Funcao da ALU
            MemToReg, // Mu3
            InstrType, // ExtendToI
            regToBan, // Mu4
            loadToMem32, // Mux6
            loadToPC; // Mux5

logic ET, GT, LT, OV; // flags da ula
logic [3:0] InstrIType; // Indicador do tipo da instrucao para extendToI 
logic [63:0]    extendToMem, // Saida em direcao a memoria
                extendToBanco; // Saida em direcao ao banco de registradores


// Instanciando PC
register PC (   .clk(clock),
                .reset(reset),
                .regWrite(PCWrite),
                .DadoIn(outMux5),
                .DadoOut(outPC)
);

// Instanciando Memoria de Instrucoes
Memoria32 InstMem (     .raddress(outMux6),
                        .waddress(),
                        .Clk(clock),
                        .Datain(),
                        .Dataout(InstMemOut),
                        .Wr(1'b0)
);

// Instanciando Memoria de Dados
Memoria64 DataMem (     .raddress(outRegAlu),
                        .waddress(outRegAlu),
                        .Clk(clock),
                        .Datain(regBOut),
                        .Dataout(DataMemOut),
                        .Wr(DMemWR)
);

// Instanciando o Registrador de Instrucoes
Instr_Reg_RISC_V InstReg (      .Clk(clock),
                                .Reset(reset),
                                .Load_ir(LoadIR),
                                .Entrada(InstMemOut),
                                .Instr19_15(Instr19_15),
                                .Instr24_20(Instr24_20),
                                .Instr11_7(Instr11_7),
                                .Instr6_0(Instr6_0),
                                .Instr31_0(Instr31_0)
);

// Instanciando a ULA
ula64 ULA (     .A(outMux1),
                .B(outMux2),
                .Seletor(AluFct),
                .S(AluOut),
                .Overflow(OV), .Negativo(), .z(), .Igual(ET), .Maior(GT), .Menor(LT)
);

// Instanciando o Banco de Registradores
bancoReg bancoRegistradores(    .write(WriteRegBanco),
                                .clock(clock),
                                .reset(reset),
                                .regreader1(Instr19_15),
                                .regreader2(Instr24_20),
                                .regwriteaddress(outMux4),
                                .datain(outMux3),
                                .dataout1(bancoRegistradoresOut1),
                                .dataout2(bancoRegistradoresOut2)
);

// Instanciando Registrador A
register regA ( .clk(clock),
                .reset(reset),
                .regWrite(LoadRegA),
                .DadoIn(bancoRegistradoresOut1),
                .DadoOut(regAOut)
);

// Instanciando Registrador B
register regB ( .clk(clock),
                .reset(reset),
                .regWrite(LoadRegB),
                .DadoIn(bancoRegistradoresOut2),
                .DadoOut(regBOut)
);

// Instanciando a Extensao de sinal
signalExtend signalExt (.clock(clock),
                        .reset(reset),
                        .Instr31_0(Instr31_0),
                        .InstrType(InstrType),
                        .outExtend(outExtend)
);

// Instanciando Registrador da Alu
register regAlu (       .clk(clock),
                        .reset(reset),
                        .regWrite(LoadAluout),
                        .DadoIn(AluOut),
                        .DadoOut(outRegAlu)
);

// Instanciando Mux 1
mux8to1 Mux1 ( .Out(outMux1),
               .Sel(AluSrcA),
               .In0(outPC), // Saida de PC
               .In1(regAOut), // Saida do Registrador A
               .In2(64'd0),
               .In3(64'd1),
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
               .In3(64'd0), 
               .In4(64'd1),
               .In5(),
               .In6(),
               .In7()
);

// Instanciando Mux 3
mux8to1 Mux3 ( .Out(outMux3),
               .Sel(MemToReg), 
               .In0(outMDR), // Saida do Registrador MDR 
               .In1(outRegAlu), // Saida da ALU
               .In2(extendToBanco), // Saida de ExtendToI
               .In3(64'd0), // 0
               .In4(64'd1), // 1
               .In5(),
               .In6(),
               .In7()
);

// Instanciando Mux 4
mux5 Mux4 ( .Out(outMux4),
               .Sel(regToBan),  
               .In0(Instr11_7), // Endereço de RD
               .In1(5'd30), // Para setar Registrador 30
               .In2(), 
               .In3(), 
               .In4(),
               .In5(),
               .In6(),
               .In7()
);

// Instanciando Mux 5
mux8to1 Mux5 ( .Out(outMux5),
               .Sel(loadToPC),  
               .In0(AluOut), 
               .In1(outExtendToPC), 
               .In2(), 
               .In3(), 
               .In4(),
               .In5(),
               .In6(),
               .In7()
);

// Instanciando Mux6
mux32 Mux6 ( .Out(outMux6),
               .Sel(loadToMem32),  
               .In0(outPC[31:0]), 
               .In1(32'd254), 
               .In2(32'd255), 
               .In3(), 
               .In4(),
               .In5(),
               .In6(),
               .In7()
);

// Instanciando Registrador MDR
register MDR (  .clk(clock),
                .reset(reset),
                .regWrite(LoadMDR),
                .DadoIn(DataMemOut),
                .DadoOut(outMDR)
);

// Instanciando Registrador EPC
register EPC (  .clk(clock),
                .reset(reset),
                .regWrite(writeEPC),
                .DadoIn(AluOut),
                .DadoOut(outEPC)
);

// Instanciando Módulo de extensao de sinal para instrucoes do tipo I
extendToI extendToI (   .clock(clock),
                        .reset(reset),
                        .InstrIType(InstrIType), // Indicador do tipo da instrucao
                        .DataMemOut(DataMemOut), // Saida da memoria de dados
                        .outMDR(outMDR), // Saida da memoria de dados depois de MDR
                        .regBOut(regBOut), // rs2 Vindo do Reg B
                        .extendToMem(extendToMem), // Saida em direcao a memoria
                        .extendToBanco(extendToBanco), // Saida em direcao ao banco de registradores
                        .regAOut(regAOut), // rs1
                        .Instr31_0(Instr31_0)
);

extendToPC extendToPC(  .clock(clock),
                        .reset(reset),
                        .InstMemOut(InstMemOut),
                        .outExtendToPC(outExtendToPC)
);

// Instanciando a Unidade de Controle
UC uc ( .clock(clock),
        .reset(reset),
        .opcode(Instr6_0), // Opcode da instrucao
        .Instr31_0(Instr31_0), // Entrada [31:0] com a instrucao
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
        .DMemWR(DMemWR), // Seletor de da Memoria de Dados
        .ET(ET), // Sinal do comparador de igualdade da ula 
        .InstrIType(InstrIType), // Indicador do tipo da instrucao
        .GT(GT), // Sinal do comparador de MaiorQue da ula 
        .LT(LT), // Sinal do comparador de MenorQue da ula
        .writeEPC(writeEPC), // Sinal de controle do EPC
        .regToBan(regToBan), // Mux4
        .loadToMem32(loadToMem32), // Mux6
        .loadToPC(loadToPC), // Mux5
        .OV(OV) // Sinal de overflow da ula
);

endmodule:UP