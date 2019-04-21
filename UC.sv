module UC (	input logic clock, reset,
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
						ET, // Sinal do comparador de igualdade da ula 
	   		output logic [2:0] 	MemToReg, // Registrador do Mux3
								AluSrcA, // Mux1
				  				AluFct, 
				  				InstrType, // Seletor informando tipo da instrucao ao Signal Extend 
                             	AluSrcB // Mux2
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

	// Instrucoes NAO SETADAS AINDA
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
	beqOrbne_estado1 = 7'd18,
	beqOrbne_estado2 = 7'd19

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
			LoadMDR = 0; // Registrador MDR 
			DMemWR = 0; // Seletor de da Memoria de Dados
			PCWrite = 1; // Incrementa PC
			AluFct = 3'b001; // SETANDO ALU PARA SOMA
			LoadIR = 0; // So no proximo ciclo
			WriteRegBanco = 0; // NAO SETADO AINDA
			AluSrcA = 3'd0; // EH ZERO MESMO
			AluSrcB = 3'd1; // INCREMENTAR PC
			LoadAluout = 0; 
			LoadRegA = 0;
			LoadRegB = 0;
			nextState = salvaInstrucao;
		end
		salvaInstrucao: begin
			LoadMDR = 0; // Registrador MDR 
			DMemWR = 0; // Seletor de da Memoria de Dados
			PCWrite = 0; // Incrementa PC
			LoadIR = 1; // So no proximo ciclo
			WriteRegBanco = 0; // NAO SETADO AINDA
			AluSrcA = 3'd0; // NAO SETADO AINDA
			AluSrcB = 3'd0; // NAO SETADO AINDA
			LoadAluout = 0; 
			LoadRegA = 0;
			LoadRegB = 0;
			nextState = decodInstrucao;
		end
		decodInstrucao: begin
			LoadMDR = 0; // Registrador MDR 
			DMemWR = 0; // Seletor de da Memoria de Dados
			PCWrite = 0; 
			LoadIR = 1; 
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
					endcase //funct3
				end
				7'b0010011: begin //I
					InstrType = 3'b000;
					case(funct3)
						3'b000: begin
							nextState = addi; // Chama addi
						end
					endcase //funct3
				end

				7'b0000011: begin//I
					InstrType = 3'b000;
					case(funct3)
						3'b011: begin
							nextState = ld_estado1; // Chama ld
						end
					endcase //funct3
				end

				7'b0100011: begin//S
					InstrType = 3'b001;
					case(funct3)
						3'b111: begin
							nextState = sd_estado1; // Chama sd						
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
					endcase
				end

				7'b0110111: begin //U
					InstrType = 3'b100;
					nextState = lui; // Chama lui
				end

			endcase //opcode

		end // decod
				
		add: begin
			PCWrite = 0; 
			LoadIR = 1;
			AluSrcA = 3'd1; // PEGA SAIDA DO REG A #
			AluSrcB = 3'd0; // PEGA SAIDA DO REG B #
			WriteRegBanco = 0; 
			LoadRegA = 0; 
			LoadRegB = 0;  
			AluFct = 3'b001; // SETANDO ALU PARA SOMA
			LoadAluout = 1;
			nextState = loadRD;
		end
		loadRD: begin // Carrega saída da ALU em RD
			PCWrite = 0; 
			LoadIR = 0;
			AluSrcA = 3'd0; 
			AluSrcB = 3'd0; 
			LoadRegA = 0; 
			LoadRegB = 0;  
			LoadAluout = 0; 
			MemToReg = 3'd1; // Mux escolhe saida da ALU
			WriteRegBanco = 1;  // Escrever em RD 
			nextState = busca;
		end
		sub: begin
			PCWrite = 0; 
			LoadIR = 1;
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
			nextState = add; // Faz a adicao normal com o sinal estendido #
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
			LoadMDR = 1; // MDR salva leitura da memória #
			nextState = ld_estado3;
		end
		ld_estado3: begin
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
		sd_estado1: begin
			// FALTA SETAR OS OUTROS SINAIS

			AluSrcA = 1; // Libera rs1 pra ALU #
			AluSrcB = 2; // Libera imm estendido pra ALU #
			AluFct =  3'b001; // Seta a função de somar (+) #
			LoadAluout = 1; // Libera a saída da ALU #
			nextState = sd_estado2;
		end
		sd_estado2: begin
			// FALTA SETAR OS OUTROS SINAIS

			// Vamos escrever na memória agora #
			//Escreve no endereço saído da ALU o conteúdo de rs2 #
			DMemWR = 1; // Mem 64 escreve DataIn no End de saída da ALU # 
			nextState = busca;
		end
		beq: begin
			// FALTA SETAR OS OUTROS SINAIS

			if (ET == 1) begin
				nextState = beqOrbne_estado1;
			end
			else begin
				nextState = busca;
			end
		end
		bne: begin
			// FALTA SETAR OS OUTROS SINAIS

			if (ET == 0) begin
				nextState = beqOrbne_estado1;
			end
			else begin
				nextState = busca;
			end
		end
		beqOrbne_estado1: begin
			// FALTA SETAR OS OUTROS SINAIS

			// Concatena um zero à direita de imm #
			// Estende o sinal de imm #
			// Shift de 1 em imm #
			nextState = beqOrbne_estado2;
		end
		beqOrbne_estado2: begin
			// FALTA SETAR OS OUTROS SINAIS

			AluSrcA = 0; // Libera PC pra ALU #
			// AluSrcB = (3 ou 2); // Imm com ++ [0], sinal est. e shift<-2 pra ALU #
			AluFct =  3'b001; // Seta a função de somar (+) #
			PCWrite = 1; // Escreve o resultado (Aluresult) em PC #
			nextState = busca;
		end
		lui: begin
		end
	endcase
end


endmodule:UC




