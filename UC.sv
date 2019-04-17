
module UC (input logic clock, reset,
           input logic [6:0] opcode, // Opcode (Instr6_0) saido do Registrador de Instrucoes
           input logic [31:0] Instr31_0, // Instrucao inteira saida do Registrador de instrucoes
           output logic LoadIR, // Registrador de Instrucoes
                        PCWrite, // PC
                        WriteRegBanco, // Banco de Registradores
                        LoadRegA, // Registrador A
                        LoadRegB, // Registrador B
                        InstrType, // Seletor informando tipo da instrucao ao Signal Extend 
			 // Seletor da ALU
                        LoadMDR, // Registrador MDR 
			LoadAluout, // Registrador da AluOut
			DMemWR, // Seletor de da Memoria de Dados
	   output logic [2:0] MemToReg, // Registrador do Mux3
                       	      AluSrcA, // Mux1
			      AluFct,
                              AluSrcB // Mux2
           );

//Inicializa todos os sinais
//LoadIR = 0
//PCWrite = 0
//WriteRegBanco = 0
//LoadRegA = 0
//LoadRegB = 0
//AluSrcA = 0
//AluSrcB = 0
//InstrType = 0
//AluFct = 0
//LoadMDR = 0
//MemToReg = 0

logic [6:0] funct7;
assign funct7 = Instr31_0[31:25];

logic [2:0] funct3;
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
	loadRD = 7'd12

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
			PCWrite = 0; // Incrementa PC
			LoadIR = 0; // So no proximo ciclo
           		WriteRegBanco = 0; // NAO SETADO AINDA
			LoadAluout = 0; 
			LoadRegA = 0;
			LoadRegB = 0;
			nextState = busca;	
		end
		busca: begin
			PCWrite = 1; // Incrementa PC
			AluFct = 3'b001; // SETANDO ALU PARA SOMA
			LoadIR = 0; // So no proximo ciclo
			WriteRegBanco = 0; // NAO SETADO AINDA
            		AluSrcA = 3'd0; // É ZERO MESMO
            		AluSrcB = 3'd1; // INCREMENTAR PC
			LoadAluout = 0; 
			LoadRegA = 0;
			LoadRegB = 0;
			nextState = salvaInstrucao;
		end
		salvaInstrucao: begin
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
			PCWrite = 0; // Incrementa PC
			LoadIR = 1; // So no proximo ciclo
            		AluSrcA = 3'd0; // NAO SETADO AINDA
            		AluSrcB = 3'd0; // NAO SETADO AINDA
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
                            case(funct3)
                                3'b000: begin
                                    nextState = addi; // Chama addi
                                end
                            endcase //funct3
                        end

                        7'b0000011: begin//I
                            case(funct3)
                                3'b011: begin
                                    nextState = ld; // Chama ld
                                end
                            endcase //funct3
                        end

                        7'b0100011: begin//S
                            case(funct3)
                                3'b111: begin
                                    nextState = sd; // Chama sd						
                                end
                            endcase
                        end

                        7'b1100011: begin//SB
                            case(funct3)
                                3'b000: begin
                                        nextState = beq; // Chama beq
                                end
                            endcase
                            end
                        7'b1100111: begin
                            case(funct3)
                                3'b001: begin
                                    nextState = bne; // Chama bne
                                end
                            endcase
                        end

                        7'b0110111: begin //U
                            nextState = lui; // Chama lui
                        end

                    endcase //opcode

                end // decod
		// Instrucoes NAO SETADAS AINDA
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
		loadRD: begin
			PCWrite = 0; 
			LoadIR = 0; 
            		AluSrcA = 3'd0; // PEGA SAIDA DO REG A 
            		AluSrcB = 3'd0; // PEGA SAIDA DO REG B 
			LoadRegA = 0; 
			LoadRegB = 0;  
			LoadAluout = 0; 
			MemToReg = 3'd1; // Mux escolhe saida da ALU
			WriteRegBanco = 1;  // Escrever em RD 
			nextState = busca;
		end
		sub: begin
		end
		addi: begin
		end
		ld: begin
		end
		sd: begin
		end
		beq: begin
		end
		bne: begin
		end
		lui: begin
		end
	endcase
end


endmodule:UC




