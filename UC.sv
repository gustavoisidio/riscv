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
	   		output logic [2:0] 	MemToReg, // Registrador do Mux3
								AluSrcA, // Mux1
				  				AluFct, 
				  				InstrType, // Seletor informando tipo da instrucao ao Signal Extend 
                                AluSrcB, // Mux2
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


wire logic [6:0] funct7;
assign funct7 = Instr31_0[31:25];

wire logic [2:0] funct3;
assign funct3 = Instr31_0[14:12];
				
enum logic [6:0] {
	rst = 7'd0,
	busca = 7'd1,
	salvaInstrucao = 7'd2,
	decodInstrucao = 7'd11, // CORRIGIR A ORDEM DAS INSTRUCOES!!!

	add = 7'd3,
	sub = 7'd4,
	addi = 7'd5,
	ld = 7'd6,
	sd = 7'd7,
	beq = 7'd8,
	bne = 7'd9,
	lui = 7'd10,
	loadRD = 7'd12,
	ld_estado1 = 7'd13,
	ld_estado2 = 7'd14,
	ld_estado3 = 7'd15,
	sd_estado1 = 7'd16,
	sd_estado2 = 7'd17,
	ld_estado4 = 7'd18,
    beqOrbne = 7'd19,
    and = 7'd20,
    slt = 7'd21,
    slti = 7'd22,
    setOnLessThan = 7'd23,
    jal_estado1 = 7'd24,
    jal_estado2 = 7'd25,
    jal_estado3 = 7'd26,
    jalr_estado1 = 7'd27,
    jalr_estado2 = 7'd28,
    jalr_estado3 = 7'd29,
    bge = 7'd30,
    blt = 7'd31,
    sw = 7'd32,
    sh = 7'd33,
    sb = 7'd34,
    lb = 7'd35,
    lbu = 7'd36,
    lhu = 7'd37,
    lwu = 7'd38

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
			LoadMDR = 0; // Registrador MDR 
			DMemWR = 0; // Seletor de da Memoria de Dados
			PCWrite = 0; // Incrementa PC
			LoadIR = 0; // So no proximo ciclo
			WriteRegBanco = 0; // NAO SETADO AINDA
			LoadAluout = 0; 
			LoadRegA = 0;
			LoadRegB = 0;
			nextState = busca;	
		end
		busca: begin
			LoadMDR = 0; 
			DMemWR = 0; 
			LoadIR = 0; 
			WriteRegBanco = 0; 
			LoadAluout = 0; 
			LoadRegA = 0;
			LoadRegB = 0;

			PCWrite = 1; // Libera escrita em PC para incrementar #
			AluFct = 3'b001; // SETANDO ALU PARA SOMA #
			AluSrcA = 3'd0; // EH ZERO MESMO #
			AluSrcB = 3'd1; // LIBERA 4 PRA INCREMENTAR PC #
			nextState = salvaInstrucao;
		end
		salvaInstrucao: begin
			LoadMDR = 0; 
			DMemWR = 0; 
			PCWrite = 0; 
			WriteRegBanco = 0; 
			AluSrcA = 3'd0; 
			AluSrcB = 3'd0; 
			LoadAluout = 0; 
			LoadRegA = 0;
			LoadRegB = 0;

			LoadIR = 1; // So no proximo ciclo #
			nextState = decodInstrucao;
		end
		decodInstrucao: begin
			LoadMDR = 0; // Registrador MDR 
			DMemWR = 0; // Seletor de da Memoria de Dados
			PCWrite = 0; 
			LoadIR = 0; 
			AluSrcA = 3'd0; 
			AluSrcB = 3'd0; 
			LoadAluout = 0;

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
                                7'b0000000: nextState = and;
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
                                    nextState = srli;
                                end
                                6'b010000: begin
                                    nextState = srai;
                                end
                            endcase //funct6
                        end
                        3'b001: begin
                            nextState = slli;
                        end
					endcase //funct3
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
                    state <= breaker;
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
                            nextState = jalr;
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
                    nextState = jal;
                end
                default: begin
                    nextState = excecao_opcode;
                end

			endcase //opcode

		end // decod
				
		add: begin
			PCWrite = 0; 
			LoadIR = 0;
			WriteRegBanco = 0; 
			LoadRegA = 0; 
			LoadRegB = 0; 

			AluSrcA = 3'd1; // PEGA SAIDA DO REG A #
			AluSrcB = 3'd0; // PEGA SAIDA DO REG B #
			AluFct = 3'b001; // SETANDO ALU PARA SOMA #
			LoadAluout = 1; // LIBERANDO SAIDA DA ALU #
			nextState = loadRD;
		end
		loadRD: begin // Carrega saida da ALU em RD
			PCWrite = 0; 
			LoadIR = 0;
			AluSrcA = 3'd0; 
			AluSrcB = 3'd0; 
			LoadRegA = 0; 
			LoadRegB = 0;  
			LoadAluout = 0; 

			MemToReg = 3'd1; // Mux escolhe saida da ALU #
			WriteRegBanco = 1;  // Escrever em RD #
			nextState = busca;
		end
		sub: begin
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
			LoadIR = 0; // Registrador de Instrucoes
			PCWrite = 0; // PC
			WriteRegBanco = 0; // Banco de Registradores
			LoadRegA = 0; // Registrador A
			LoadRegB = 0; // Registrador B
			LoadMDR = 0; // Registrador MDR 
			LoadAluout = 0; // Registrador da AluOut
			DMemWR = 0; // Seletor de da Memoria de Dados

			AluSrcA = 3'd1; // Libera rs1 pra ALU #
			AluSrcB = 3'd2; // Libera imm extendido pra ALU #
			AluFct = 3'b001; // SETANDO ALU PARA SOMA #
			LoadAluout = 1; // LIBERANDO SAIDA DA ALU #
			nextState = loadRD;
        end
        lb: begin
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados

            nextState = ld_estado1;
        end
        lh: begin
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados

            nextState = ld_estado1;
        end
        lw: begin
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados

            nextState = ld_estado1;
        end
        lbu: begin 
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados

            nextState = ld_estado1;
        end
        lhu: begin
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados

            nextState = ld_estado1;
        end
        lwu: begin
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados

            nextState = ld_estado1;
        end
		ld_estado1: begin
			LoadIR = 0; // Registrador de Instrucoes
			PCWrite = 0; // PC
			WriteRegBanco = 0; // Banco de Registradores
			LoadRegA = 0; // Registrador A
			LoadRegB = 0; // Registrador B
			LoadMDR = 0; // Registrador MDR 
			LoadAluout = 0; // Registrador da AluOut
			DMemWR = 0; // Seletor de da Memoria de Dados

			AluSrcA = 1; // Libera rs1 pra ALU #
			AluSrcB = 2; // Libera imm estendido pra ALU #
			AluFct =  3'b001; // Seta a função de somar (+) #
			LoadAluout = 1; // Libera a saída da ALU #
			nextState = ld_estado2;
		end
		ld_estado2: begin // Vamos buscar na memória agora
			LoadIR = 0; // Registrador de Instrucoes
			PCWrite = 0; // PC
			LoadRegA = 0; // Registrador A
			LoadRegB = 0; // Registrador B
			LoadMDR = 0; // Registrador MDR 
			LoadAluout = 0; // Registrador da AluOut

			DMemWR = 0; // Mem 64 lê (endereço) a saída da ALU #
			nextState = ld_estado3;
		end
		ld_estado3: begin // Vamos buscar na memória agora
			LoadIR = 0; // Registrador de Instrucoes
			PCWrite = 0; // PC
			LoadRegA = 0; // Registrador A
			LoadRegB = 0; // Registrador B
			LoadMDR = 0; // Registrador MDR 
			LoadAluout = 0; // Registrador da AluOut

			LoadMDR = 1; // MDR salva leitura da memória #
			nextState = ld_estado4;
		end
		ld_estado4: begin
			LoadIR = 0; // Registrador de Instrucoes
			PCWrite = 0; // PC
			WriteRegBanco = 0; // Banco de Registradores
			LoadRegA = 0; // Registrador A
			LoadRegB = 0; // Registrador B
			LoadMDR = 0; // Registrador MDR 
			LoadAluout = 0; // Registrador da AluOut
			DMemWR = 0; // Seletor de da Memoria de Dados

			MemToReg = 0; // Se adianta e seleciona a saída da memória pro banco #
			WriteRegBanco = 1;  // Escrever em RD #
			nextState = busca;
        end
        sw: begin
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados

            nextState = sd_estado1;
        end
        sh: begin
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados

            nextState = sd_estado1;
        end
        sb: begin
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados

            nextState = sd_estado1;
        end
		sd_estado1: begin
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            DMemWR = 0; // Seletor de da Memoria de Dados


			AluSrcA = 1; // Libera rs1 pra ALU #
			AluSrcB = 2; // Libera imm estendido pra ALU #
			AluFct =  3'b001; // Seta a função de somar (+) #
			LoadAluout = 1; // Libera a saída da ALU #
			nextState = sd_estado2;
		end
		sd_estado2: begin
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut

			// Vamos escrever na memória agora #
			//Escreve no endereço saído da ALU o conteúdo de rs2 #
			DMemWR = 1; // Mem 64 escreve DataIn no End de saída da ALU # 
			nextState = busca;
		end
		beq: begin
			LoadIR = 0; // Registrador de Instrucoes
			PCWrite = 0; // PC
			WriteRegBanco = 0; // Banco de Registradores
			LoadRegA = 0; // Registrador A
			LoadRegB = 0; // Registrador B
			LoadMDR = 0; // Registrador MDR 
			LoadAluout = 0; // Registrador da AluOut
			DMemWR = 0; // Seletor de da Memoria de Dados

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
			LoadIR = 0; // Registrador de Instrucoes
			PCWrite = 0; // PC
			WriteRegBanco = 0; // Banco de Registradores
			LoadRegA = 0; // Registrador A
			LoadRegB = 0; // Registrador B
			LoadMDR = 0; // Registrador MDR 
			LoadAluout = 0; // Registrador da AluOut
			DMemWR = 0; // Seletor de da Memoria de Dados

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
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados

            AluSrcA = 1 // Libera conteúdo de A (rs1) para ALU #
            AluSrcB = 0 // Libera conteúdo de B (rs2) para ALU #
            AluFct = 111 // Para fazer comparacao #
        
                if (LT == 0) begin // (rs1 >= rs2)
                    nextState = beqOrbne;
                end
                else begin
                    nextState = busca;
                end
        end
        blt: begin
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados

            AluSrcA = 1 // Libera conteúdo de A (rs1) para ALU #
            AluSrcB = 0 // Libera conteúdo de B (rs2) para ALU #
            AluFct = 111 // Para fazer comparacao #
        
                if (LT == 1) begin // (rs1 < rs2)
                    nextState = beqOrbne;
                end
                else begin 
                    nextState = busca;
                end
        end
		beqOrbne: begin
			LoadIR = 0; // Registrador de Instrucoes
			WriteRegBanco = 0; // Banco de Registradores
			LoadRegA = 0; // Registrador A
			LoadRegB = 0; // Registrador B
			LoadMDR = 0; // Registrador MDR 
			LoadAluout = 0; // Registrador da AluOut
			DMemWR = 0; // Seletor de da Memoria de Dados

			AluSrcA = 0; // Libera PC pra ALU
			AluSrcB = 2; // Imm com ++ [0], sinal est. e shift<-2 pra ALU
			AluFct =  3'b001; // Seta a função de somar (+)
			PCWrite = 1; // Escreve o resultado (Aluresult) em PC
			nextState = busca;
		end
		lui: begin
			LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            DMemWR = 0; // Seletor de da Memoria de Dados

            AluSrcA = 2; // Liberando 0 pra ALU #
            AluSrcB = 2; // Liberando saida do signalExtend #
            AluFct = 3'b001; // SETANDO ALU PARA SOMA #
            LoadAluout = 1; // LIBERANDO SAIDA DA ALU #
            nextState = loadRD;
        end
        and: begin
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            DMemWR = 0; // Seletor de da Memoria de Dados

            AluSrcA = 1; // Libera conteúdo de A (rs1) para ALU #
            AluSrcB = 0; // Libera conteúdo de B (rs2) para ALU #
            AluFct = 3'b011; // Seta and logico na ALU #
            LoadAluout = 1; // Liberando saida da ALU #
            nextState = loadRD;
        end
        slt: begin
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados

        	AluSrcA = 1 // Libera conteúdo de A (rs1) para ALU #
	        AluSrcB = 0 // Libera conteúdo de B (rs2) para ALU #
            nextState = setOnLessThan;
        end
        slti: begin
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados

            AluSrcA = 1 // Libera conteúdo de A (rs1) para ALU #
            AluSrcB = 2 // Libera o immediato estendido para ALU #
            nextState = setOnLessThan;
        end
        setOnLessThan: begin
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            DMemWR = 0; // Seletor de da Memoria de Dados

            AluFct = 111; // Para fazer comparacao #
                if (LT == 1) begin // Carrega 1 em RD #
                    AluSrcA = 2 // Libera 0 para ALU #
                    AluSrcB = 4 // Libera 1 para ALU #
                    AluFct =  3'b001 // Soma 1 + 0 #
                    LoadAluout = 1; // Liberando 1 saido da ALU #
                    nextState = LoadRD;
                end
                else begin // Carrega 0 em RD
                    AluSrcA = 2 // Libera 0 para ALU #
                    AluSrcB = 3 // Libera 0 para ALU #
                    AluFct =  3'b001 // Soma 0 + 0 #
                    LoadAluout = 1; // Liberando 0 saido da ALU #
                    nextState = LoadRD;
                end
        end 
        jalr_estado1: begin
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            DMemWR = 0; // Seletor de da Memoria de Dados

            AluSrcA = 0 // Libera conteúdo de PC para ALU #
            AluSrcB = 3 // Libera 0 para ALU (falta adicionar entrada 0 no mux) #
            AluFct =  3'b001 // Soma PC + 0 pra obter PC na AluOut #
            LoadAluout = 1; // Liberando PC saido da ALU #
            nextState = jalr_estado2;
        end
        jalr_estado2 begin // Carregando em RD
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados

            MemToReg = 1 // Seleciona a saída da AluOut para o banco de reg #
            WriteRegBanco = 1;  // Escrever PC em RD #
            nextState = jalr_estado3;
        end
        jalr_estado3: begin // Alterando PC
            LoadIR = 0; // Registrador de Instrucoes
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados

            AluSrcA = 1 // Libera conteúdo de A (rs1) para ALU #
            AluSrcB = 2 // Libera o immediato estendido para ALU #
            AluFct =  3'b001 // Soma rs1 com imm #
            PCWrite = 1 // Escreve o resultado (Aluresult) em PC #
            nextState = busca;
        end
        jal_estado1: begin
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            DMemWR = 0; // Seletor de da Memoria de Dados

            AluSrcA = 0 // Libera conteúdo de PC para ALU #
            AluSrcB = 3 // Libera 0 para ALU #
            AluFct =  3'b001 // Soma PC + 0 pra obter PC na AluOut #
            LoadAluout = 1; // Liberando PC saido da ALU #
            nextState = jal_estado2;
        end
        jal_estado2: begin // Carregando em RD #
            LoadIR = 0; // Registrador de Instrucoes
            PCWrite = 0; // PC
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados

            MemToReg = 1 // Seleciona a saída da AluOut para o banco de reg #
            WriteRegBanco = 1;  // Escrever PC em RD #
            nextState = jal_estado3;
        end
        jal_estado3: begin // Altera valor de PC
            LoadIR = 0; // Registrador de Instrucoes
            WriteRegBanco = 0; // Banco de Registradores
            LoadRegA = 0; // Registrador A
            LoadRegB = 0; // Registrador B
            LoadMDR = 0; // Registrador MDR 
            LoadAluout = 0; // Registrador da AluOut
            DMemWR = 0; // Seletor de da Memoria de Dados

            AluSrcA = 0 // Libera conteúdo de PC para ALU #
            AluSrcB = 2 // Libera immediato estendido ALU #
            AluFct =  3'b001 // Soma PC + imm #
            PCWrite = 1 // Escreve o resultado (Aluresult) em PC #
            nextState = busca;
        end
	endcase
end


endmodule:UC




