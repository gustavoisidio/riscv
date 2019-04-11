module UP(input logic clock, reset);

logic [6:0] estado;
logic [63:0] AluOut, outPC;
logic [31:0] InstMemOut, Instr31_0; // 1 - Saida da Memoria de Instrucoes, 2 - Saida do registrador de Instrucoes para extensao de sinal e/ou shift
logic [64-1:0] bancoRegistradoresOut1, bancoRegistradoresOut2; // Saidas do Banco de Registradores
logic LoadIR, PCWrite, WriteReg, LoadRegA, LoadRegB, AluSrcA, AluSrcB; // Sinais de controle / Saida da Unidade de Controle
logic [4:0] Instr19_15, Instr24_20, Instr11_7; // Segmentacao da Instrucao / Saida do Registrador de Instrucoes
logic [6:0] Instr6_0;
logic [63:0] regAOut, regBOut; // Saida dos registradores A e B

// Instanciando PC
register PC (.clk(clock), .reset(reset), .regWrite(PCWrite), .DadoIn(AluOut), .DadoOut(outPC));

// Instanciando Memoria de Instrucoes
Memoria32 InstMem (.raddress(outPC[31:0]), .waddress(), .Clk(clock), .Datain(), .Dataout(InstMemOut), .Wr(1'b0));

// Instanciando o Registrador de Instrucoes
Instr_Reg_RISC_V InstReg (.Clk(clock), .Reset(reset), .Load_ir(LoadIR), .Entrada(InstMemOut), .Instr19_15(Instr19_15), .Instr24_20(Instr24_20), .Instr11_7(Instr11_7), .Instr6_0(Instr6_0), .Instr31_0(Instr31_0));

// Instanciando a ULA
ula64 ULA (.A(outPC), .B(64'd4), .Seletor(3'b001), .S(AluOut), .Overflow(), .Negativo(), .z(), .Igual(), .Maior(), .Menor());

// Instanciando o Banco de Registradores
bancoReg bancoRegistradores(.write(WriteReg), .clock(clock), .reset(reset), .regreader1 (Instr19_15), .regreader2(Instr24_20), .regwriteaddress(Instr11_7), .datain(), .dataout1(bancoRegistradoresOut1), .dataout2(bancoRegistradoresOut1));

// Instanciando Registrador A
register regA (.clk(clock), .reset(reset), .regWrite(LoadRegA), .DadoIn(bancoRegistradoresOut1), .DadoOut(regAOut));

// Instanciando Registrador B
register regB (.clk(clock), .reset(reset), .regWrite(LoadRegB), .DadoIn(bancoRegistradoresOut2), .DadoOut(regBOut));

// Instanciando Mux 1
mux8to1 Mux1 ( .Out(),
               .Sel(AluSrcA),
               .In0(outPC),
               .In1(regAOut),
               .In2(),
               .In3(),
               .In4(),
               .In5(),
               .In6(),
               .In7()
            );

// Instanciando Mux 2
mux8to1 Mux2 ( .Out(),
               .Sel(AluSrcB),
               .In0(regBOut),
               .In1(64'd4), // 4, para PC + 4
               .In2(), // Extensao
               .In3(), // Shift
               .In4(),
               .In5(),
               .In6(),
               .In7()
             );             

// Instanciando a Unidade de Controle
UC uc (.clock(clock), .reset(reset), .opcode(Instr6_0), .Instr31_0(), .estado(estado), .LoadIR(LoadIR), .PCWrite(PCWrite), .WriteReg(WriteReg), .LoadRegA(LoadRegA), .LoadRegB(LoadRegB), .InstrType());

endmodule:UP