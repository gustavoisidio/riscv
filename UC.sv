module UC (	input logic clock, reset, ET, GT, LT,
           	input logic [6:0] opcode, // Opcode (Instr6_0) saido do Registrador de Instrucoes
           	input logic [31:0] Instr31_0, // Instrucao inteira saida do Registrador de instrucoes
           	output logic LoadIR, // Registrador de Instrucoes
                        PCWrite, // PC
                        WriteRegBanco, // Banco de Registradores
                        LoadRegA, // Registrador A
                        LoadRegB, // Registrador B
                        LoadMDR, // Registrador MDR 
						LoadAluout, // Registrador da AluOut
                        DMemWR, // Seletor de da Memoria de Dados
                        writeEPC, // Seletor do MDR
	   		output logic [2:0] 	MemToReg, // Mux3
								AluSrcA, // Mux1
				  				AluFct, 
				  				InstrType, // Seletor informando tipo da instrucao ao Signal Extend 
                                AluSrcB, // Mux2
                                regToBan, // Mux4 default = 0, Instr11_7
                                loadToPC, // Mux5 default: 0, Aluout
                                loadToMem32, // Mux6 default: 0, PC
            output logic [3:0] InstrIType // Indicador do tipo da instrucao para extendToI 
);

// LoadIR = 0; // Registrador de Instrucoes
// PCWrite = 0; // PC
// WriteRegBanco = 0; // Banco de Registradores
// LoadRegA = 0; // Registrador A
// LoadRegB = 0; // Registrador B
// LoadMDR = 0; // Registrador MDR 
// LoadAluout = 0; // Registrador da AluOut
// DMemWR = 0; // Seletor de da Memoria de Dados
// writeEPC = 0; // Seletor do EPC
// regToBan = 0; // Mux4 default = 0, Instr11_7
// loadToPC = 0; // Mux5 default: 0, Aluout
// loadToMem32 = 0; // Mux6 default: 0, PC


wire logic [6:0] funct7;
assign funct7 = Instr31_0[31:25];

wire logic [2:0] funct3;
assign funct3 = Instr31_0[14:12];

wire logic [5:0] funct6;
assign funct6 = Instr31_0[31:25];

wire logic [5:0] shamt;
assign shamt = Instr31_0[24:18];


enum logic [7:0] {  rst,
                    busca,
                    salvaInstrucao,
                    decodInstrucao,
                    add,
                    sub,
                    addi,
                    ld,
                    sd,
                    beq,
                    bne,
                    lui,
                    loadRD,
                    ld_estado1,
                    ld_estado2,
                    ld_estado3,
                    sd_estado1,
                    sd_estado2,
                    ld_estado4,
                    beqOrbne,
                    and_estado,
                    slt,
                    slti,
                    setOnLessThan,
                    jal_estado1,
                    jal_estado2,
                    jal_estado3,
                    jalr_estado1,
                    jalr_estado2,
                    jalr_estado3,
                    bge,
                    blt,
                    sw,
                    sh,
                    sb,
                    lb,
                    lbu,
                    lhu,
                    lwu,
                    lw,
                    lh,
                    breaker,
                    noop,
                    srli,
                    srai,
                    slli,
                    loadShift,
                    excecao_opcode,
                    excecao_overflow
} state, nextState;


always_ff @(posedge clock, posedge reset) begin
	if (reset) begin
		state <= rst;
    end else begin
		state <= nextState;
    end
end


always_comb begin
	case (state)
        rst: begin
            writeEPC = 0;
			LoadMDR = 0; // Registrador MDR 
			DMemWR = 0; // Seletor de da Memoria de Dados
			PCWrite = 0; // Incrementa PC
			LoadIR = 0; // So no proximo ciclo
            WriteRegBanco = 0; // NAO SETADO AINDA
            loadToPC = 0; // Mux5 default: Aluout
            loadToMem32 = 0; // Mux6 default: PC
            regToBan = 0; // Mux4 default = 0, Instr11_7

			LoadAluout = 0; 
			LoadRegA = 0;
			LoadRegB = 0;
			nextState = busca;	
		end
        busca: begin
            writeEPC = 0;
			LoadMDR = 0; 
			DMemWR = 0; 
			LoadIR = 0; 
			WriteRegBanco = 0; 
			LoadAluout = 0; 
			LoadRegA = 0;
            LoadRegB = 0;
            loadToPC = 0; // Mux5 default: Aluout
            loadToMem32 = 0; // Mux6 default: PC
            regToBan = 0; // Mux4 default = 0, Instr11_7

			PCWrite = 1; // Libera escrita em PC para incrementar #
			AluFct = 3'b001; // SETANDO ALU PARA SOMA #
			AluSrcA = 3'd0; // SELECIONA PC #
			AluSrcB = 3'd1; // LIBERA 4 PRA INCREMENTAR PC #
			nextState = salvaInstrucao;
		end
        salvaInstrucao: begin
            writeEPC = 0;
			LoadMDR = 0; 
			DMemWR = 0; 
			PCWrite = 0; 
			WriteRegBanco = 0; 
			AluSrcA = 3'd0; 
			AluSrcB = 3'd0; 
			LoadAluout = 0; 
			LoadRegA = 0;
            LoadRegB = 0;
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

			LoadIR = 1; // So no proximo ciclo #
			nextState = decodInstrucao;
		end
        decodInstrucao: begin
            writeEPC = 0;
			LoadMDR = 0; // Registrador MDR 
			DMemWR = 0; // Seletor de da Memoria de Dados
			PCWrite = 0; 
			LoadIR = 0; 
			AluSrcA = 3'd0; 
			AluSrcB = 3'd0; 
            LoadAluout = 0;
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

			WriteRegBanco = 0; // SETA LEITURA DO BANCO DE REGISTRADORES #
			LoadRegA = 1; // CARREGO EM A #
			LoadRegB = 1; // CARREGO EM B #

			case(opcode)
				7'b0110011: begin //R
					case(funct3)
						3'b000: begin
							case(funct7)
								7'b0000000: nextState = add; // Chama add
								7'b0100000: nextState = sub; // Chama sub
							endcase //funct7
                        end
                        3'b111: begin
                            case(funct7)
                                7'b0000000: nextState = and_estado;
                            endcase
                        end
                        3'b010: begin
                            case(funct7)
                                7'b0000000: nextState = slt;
                            endcase
                        end
                    endcase //funct3
				end
                
				7'b0010011: begin //I
					InstrType = 3'b000;
                    if Instr31_0[31:25] == {25'd0, opcode} begin
                        nextState = noop;
                    end
                    else begin
                        case(funct3)
                            3'b000: begin
                                nextState = addi; // Chama addi
                            end
                            3'b010: begin
                                nextState = slti;
                            end
                            3'b101: begin
                                case(funct6)
                                    6'b000000: begin
                                        InstrIType = 4'b1011;
                                        nextState = srli;
                                    end
                                    6'b010000: begin
                                        InstrIType = 4'b1101;
                                        nextState = srai;
                                    end
                                endcase //funct6
                            end
                            3'b001: begin
                                InstrIType = 4'b1011;
                                nextState = slli;
                            end
                        endcase //funct3
                    end // else
				end

				7'b0000011: begin//I
					InstrType = 3'b000;
					case(funct3)
                        3'b011: begin
                            InstrIType = 4'b1010;
							nextState = ld_estado1; // Chama ld
                        end
                        3'b010: begin
                            InstrIType = 4'b0010;
                            nextState = lw;
                        end
                        3'b001: begin
                            InstrIType = 4'b0001;
                            nextState = lh;
                        end
                        3'b100: begin
                            InstrIType = 4'b0000;
                            nextState = lb;
                        end
                        3'b100: begin
                            InstrIType = 4'b0011;
                            nextState = lbu;
                        end
                        3'b101: begin
                            InstrIType = 4'b0100;
                            nextState = lhu;
                        end
                        3'b110: begin
                            InstrIType = 4'b0101;
                            nextState = lwu;
                        end
					endcase //funct3
                end
                
                7'b1110011: begin
                    nextState = breaker;
                end

				7'b0100011: begin//S
					InstrType = 3'b001;
					case(funct3)
                        3'b111: begin
                            InstrIType = 4'b0110;
							nextState = sd_estado1; // Chama sd						
                        end
                        3'b010: begin
                            InstrIType = 4'b0111;
                            nextState = sw;
                        end
                        3'b001: begin
                            InstrIType = 4'b1000;
                            nextState = sh;
                        end
                        3'b000: begin
                            InstrIType = 4'b1001;
                            nextState = sb;
                        end
					endcase
				end

				7'b1100011: begin//SB
					InstrType = 3'b010;
					case(funct3)
						3'b000: begin
							nextState = beq; // Chama beq
						end
					endcase
					end
				7'b1100111: begin // SB
					InstrType = 3'b010;
					case(funct3)
						3'b001: begin
							nextState = bne; // Chama bne
                        end
                        3'b000: begin
                            nextState = jalr_estado1;
                        end
                        3'b101: begin
                            nextState = bge;
                        end
                        3'b100: begin
                            nextState = blt;
                        end
					endcase
				end

				7'b0110111: begin //U
					InstrType = 3'b100;
					nextState = lui; // Chama lui
                end
                
                7'b1101111: begin //UJ
                    nextState = jal_estado1;
                end
                default: begin
                    nextState = excecao_opcode;
                end

			endcase //opcode

		end // decod
				
        add: begin
            writeEPC = 0;
			PCWrite = 0; 
			LoadIR = 0;
			WriteRegBanco = 0; 
			LoadRegA = 0; 
            LoadRegB = 0;
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

			AluSrcA = 3'd1; // PEGA SAIDA DO REG A #
			AluSrcB = 3'd0; // PEGA SAIDA DO REG B #
			AluFct = 3'b001; // SETANDO ALU PARA SOMA #
			LoadAluout = 1; // LIBERANDO SAIDA DA ALU #
			nextState = loadRD;
		end
        loadRD: begin // Carrega saida da ALU em RD
            writeEPC = 0;
			PCWrite = 0; 
			LoadIR = 0;
			AluSrcA = 3'd0; 
			AluSrcB = 3'd0; 
			LoadRegA = 0; 
			LoadRegB = 0;  
            LoadAluout = 0;
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            MemToReg = 3'd1; // Mux escolhe saida da ALU #
            regToBan = 0; // Selecionando Instr11_7 #
			WriteRegBanco = 1;  // Escrever em RD #
			nextState = busca;
		end
        sub: begin
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC
            writeEPC = 0;
			PCWrite = 0; 
			LoadIR = 0;
			AluSrcA = 3'd1; // PEGA SAIDA DO REG A #
			AluSrcB = 3'd0; // PEGA SAIDA DO REG B #
			WriteRegBanco = 0; 
			LoadRegA = 0; 
			LoadRegB = 0;  
			AluFct = 3'b010; // SETANDO ALU PARA SUBTRACAO
			LoadAluout = 1;
			nextState = loadRD;
		end
        addi: begin
            writeEPC = 0;
			LoadIR = 0; // Registrador de Instrucoes
			PCWrite = 0; // PC
			WriteRegBanco = 0; // Banco de Registradores
			LoadRegA = 0; // Registrador A
			LoadRegB = 0; // Registrador B
			LoadMDR = 0; // Registrador MDR 
			LoadAluout = 0; // Registrador da AluOut
			DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

			AluSrcA = 3'd1; // Libera rs1 pra ALU #
			AluSrcB = 3'd2; // Libera imm extendido pra ALU #
			AluFct = 3'b001; // SETANDO ALU PARA SOMA #
			LoadAluout = 1; // LIBERANDO SAIDA DA ALU #
			nextState = loadRD;
        end
        lb: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            nextState = ld_estado1;
        end
        lh: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            nextState = ld_estado1;
        end
        lw: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            nextState = ld_estado1;
        end
        lbu: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            nextState = ld_estado1;
        end
        lhu: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            nextState = ld_estado1;
        end
        lwu: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            nextState = ld_estado1;
        end
        ld_estado1: begin
            writeEPC = 0;
			LoadIR = 0; // Registrador de Instrucoes
			PCWrite = 0; // PC
			WriteRegBanco = 0; // Banco de Registradores
			LoadRegA = 0; // Registrador A
			LoadRegB = 0; // Registrador B
			LoadMDR = 0; // Registrador MDR 
			LoadAluout = 0; // Registrador da AluOut
			DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

			AluSrcA = 1; // Libera rs1 pra ALU #
			AluSrcB = 2; // Libera imm estendido pra ALU #
			AluFct =  3'b001; // Seta a função de somar (+) #
			LoadAluout = 1; // Libera a saída da ALU #
			nextState = ld_estado2;
		end
        ld_estado2: begin // Vamos buscar na memória agora
            writeEPC = 0;
			LoadIR = 0; // Registrador de Instrucoes
			PCWrite = 0; // PC
			LoadRegA = 0; // Registrador A
			LoadRegB = 0; // Registrador B
			LoadMDR = 0; // Registrador MDR 
			LoadAluout = 0; // Registrador da AluOut
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

			DMemWR = 0; // Mem 64 lê (endereço) a saída da ALU #
			nextState = ld_estado3;
		end
        ld_estado3: begin // Vamos buscar na memória agora
            writeEPC = 0;
			LoadIR = 0; // Registrador de Instrucoes
			PCWrite = 0; // PC
			LoadRegA = 0; // Registrador A
			LoadRegB = 0; // Registrador B
			LoadMDR = 0; // Registrador MDR 
			LoadAluout = 0; // Registrador da AluOut
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

			LoadMDR = 1; // MDR salva leitura da memória #
			nextState = ld_estado4;
		end
        ld_estado4: begin
            writeEPC = 0;
			LoadIR = 0; // Registrador de Instrucoes
			PCWrite = 0; // PC
			WriteRegBanco = 0; // Banco de Registradores
			LoadRegA = 0; // Registrador A
			LoadRegB = 0; // Registrador B
			LoadMDR = 0; // Registrador MDR 
			LoadAluout = 0; // Registrador da AluOut
			DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            MemToReg = 0; // Se adianta e seleciona a saída da memória pro banco #
            regToBan = 0; // Selecionando Instr11_7 #
			WriteRegBanco = 1;  // Escrever em RD #
			nextState = busca;
        end
        sw: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            nextState = sd_estado1;
        end
        sh: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            nextState = sd_estado1;
        end
        sb: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            nextState = sd_estado1;
        end
        sd_estado1: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

			AluSrcA = 1; // Libera rs1 pra ALU #
			AluSrcB = 2; // Libera imm estendido pra ALU #
			AluFct =  3'b001; // Seta a função de somar (+) #
			LoadAluout = 1; // Libera a saída da ALU #
			nextState = sd_estado2;
		end
        sd_estado2: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

			// Vamos escrever na memória agora #
			//Escreve no endereço saído da ALU o conteúdo de rs2 #
			DMemWR = 1; // Mem 64 escreve DataIn no End de saída da ALU # 
			nextState = busca;
		end
        beq: begin
            writeEPC = 0;
			LoadIR = 0; // Registrador de Instrucoes
			PCWrite = 0; // PC
			WriteRegBanco = 0; // Banco de Registradores
			LoadRegA = 0; // Registrador A
			LoadRegB = 0; // Registrador B
			LoadMDR = 0; // Registrador MDR 
			LoadAluout = 0; // Registrador da AluOut
			DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

			AluSrcA = 1; // Libera conteúdo de A (rs1) para ALU #
			AluSrcB = 0; // Libera conteúdo de B (rs2) para ALU #
			AluFct = 111; // Para checar Igualdade #
		
			if (ET == 1) begin
				nextState = beqOrbne;
			end
			else begin
				nextState = busca;
			end
		end
        bne: begin
            writeEPC = 0;
			LoadIR = 0; // Registrador de Instrucoes
			PCWrite = 0; // PC
			WriteRegBanco = 0; // Banco de Registradores
			LoadRegA = 0; // Registrador A
			LoadRegB = 0; // Registrador B
			LoadMDR = 0; // Registrador MDR 
			LoadAluout = 0; // Registrador da AluOut
			DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

			AluSrcA = 1; // Libera conteúdo de A (rs1) para ALU #
			AluSrcB = 0; // Libera conteúdo de B (rs2) para ALU #
			AluFct = 111; // Para checar Igualdade #

			if (ET == 0) begin
				nextState = beqOrbne;
			end
			else begin
				nextState = busca;
			end
        end
        bge: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            AluSrcA = 1; // Libera conteúdo de A (rs1) para ALU #
            AluSrcB = 0; // Libera conteúdo de B (rs2) para ALU #
            AluFct = 111; // Para fazer comparacao #
        
                if (LT == 0) begin // (rs1 >= rs2)
                    nextState = beqOrbne;
                end
                else begin
                    nextState = busca;
                end
        end
        blt: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            AluSrcA = 1; // Libera conteúdo de A (rs1) para ALU #
            AluSrcB = 0; // Libera conteúdo de B (rs2) para ALU #
            AluFct = 111; // Para fazer comparacao #
        
                if (LT == 1) begin // (rs1 < rs2)
                    nextState = beqOrbne;
                end
                else begin 
                    nextState = busca;
                end
        end
        beqOrbne: begin
            writeEPC = 0;
			LoadIR = 0; // Registrador de Instrucoes
			WriteRegBanco = 0; // Banco de Registradores
			LoadRegA = 0; // Registrador A
			LoadRegB = 0; // Registrador B
			LoadMDR = 0; // Registrador MDR 
			LoadAluout = 0; // Registrador da AluOut
			DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

			AluSrcA = 0; // Libera PC pra ALU
			AluSrcB = 2; // Imm com ++ [0], sinal est. e shift<-2 pra ALU
			AluFct =  3'b001; // Seta a função de somar (+)
			PCWrite = 1; // Escreve o resultado (Aluresult) em PC
			nextState = busca;
		end
        lui: begin
            writeEPC = 0;
			LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            AluSrcA = 2; // Liberando 0 pra ALU #
            AluSrcB = 2; // Liberando saida do signalExtend #
            AluFct = 3'b001; // SETANDO ALU PARA SOMA #
            LoadAluout = 1; // LIBERANDO SAIDA DA ALU #
            nextState = loadRD;
        end
        and_estado: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            AluSrcA = 1; // Libera conteúdo de A (rs1) para ALU #
            AluSrcB = 0; // Libera conteúdo de B (rs2) para ALU #
            AluFct = 3'b011; // Seta and logico na ALU #
            LoadAluout = 1; // Liberando saida da ALU #
            nextState = loadRD;
        end
        slt: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

        	AluSrcA = 1; // Libera conteúdo de A (rs1) para ALU #
	        AluSrcB = 0; // Libera conteúdo de B (rs2) para ALU #
            nextState = setOnLessThan;
        end
        slti: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            AluSrcA = 1; // Libera conteúdo de A (rs1) para ALU #
            AluSrcB = 2; // Libera o immediato estendido para ALU #
            nextState = setOnLessThan;
        end
        setOnLessThan: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            AluFct = 111; // Para fazer comparacao #
                if (LT == 1) begin // Carrega 1 em RD #
                    AluSrcA = 2; // Libera 0 para ALU #
                    AluSrcB = 4; // Libera 1 para ALU #
                    AluFct =  3'b001; // Soma 1 + 0 #
                    LoadAluout = 1; // Liberando 1 saido da ALU #
                    nextState = loadRD;
                end
                else begin // Carrega 0 em RD
                    AluSrcA = 2; // Libera 0 para ALU #
                    AluSrcB = 3; // Libera 0 para ALU #
                    AluFct =  3'b001; // Soma 0 + 0 #
                    LoadAluout = 1; // Liberando 0 saido da ALU #
                    nextState = loadRD;
                end
        end 
        jalr_estado1: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            AluSrcA = 0; // Libera conteúdo de PC para ALU #
            AluSrcB = 3; // Libera 0 para ALU (falta adicionar entrada 0 no mux) #
            AluFct =  3'b001; // Soma PC + 0 pra obter PC na AluOut #
            LoadAluout = 1; // Liberando PC saido da ALU #
            nextState = jalr_estado2;
        end
        jalr_estado2: begin // Carregando em RD
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            MemToReg = 1; // Seleciona a saída da AluOut para o banco de reg #
            regToBan = 0; // Selecionando Instr11_7 #
            WriteRegBanco = 1;  // Escrever PC em RD #
            nextState = jalr_estado3;
        end
        jalr_estado3: begin // Alterando PC
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            AluSrcA = 1; // Libera conteúdo de A (rs1) para ALU #
            AluSrcB = 2; // Libera o immediato estendido para ALU #
            AluFct =  3'b001; // Soma rs1 com imm #
            PCWrite = 1; // Escreve o resultado (Aluresult) em PC #
            nextState = busca;
        end
        jal_estado1: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            AluSrcA = 0; // Libera conteúdo de PC para ALU #
            AluSrcB = 3; // Libera 0 para ALU #
            AluFct =  3'b001; // Soma PC + 0 pra obter PC na AluOut #
            LoadAluout = 1; // Liberando PC saido da ALU #
            nextState = jal_estado2;
        end
        jal_estado2: begin // Carregando em RD #
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            MemToReg = 1; // Seleciona a saída da AluOut para o banco de reg #
            regToBan = 0; // Selecionando Instr11_7 #
            WriteRegBanco = 1;  // Escrever PC em RD #
            nextState = jal_estado3;
        end
        jal_estado3: begin // Altera valor de PC
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PC

            AluSrcA = 0; // Libera conteúdo de PC para ALU #
            AluSrcB = 2; // Libera immediato estendido ALU #
            AluFct =  3'b001; // Soma PC + imm #
            PCWrite = 1; // Escreve o resultado (Aluresult) em PC #
            nextState = busca;
        end
        srli: begin
            nextState = loadShift;
        end
        srai: begin
            nextState = loadShift;
        end
        slli: begin
            nextState = loadShift;
        end
        loadShift: begin
            writeEPC = 0;
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados
            regToBan = 0; // Mux4 default = 0, Instr11_7
            loadToPC = 0; // Mux5 default: 0, Aluout
            loadToMem32 = 0; // Mux6 default: 0, PCs

            MemToReg = 3'd2; // Mux escolhe saida do ExtendToI #
            regToBan = 0; // Selecionando Instr11_7 #
			WriteRegBanco = 1;  // Escrever em RD #
			nextState = busca;
        end
        breaker: begin
            nextState = breaker;
        end
        noop: begin
            nextState = busca;
        end
        excecao_opcode: begin
            // Salva PCe EPC
            // PC = PC - 4
            // Reg 30 = 0
        end
        excecao_overflow: begin
            // Salva PCe EPC
            // PC = PC - 4
            // Reg 30 = 1
        end
	endcase
end


endmodule




