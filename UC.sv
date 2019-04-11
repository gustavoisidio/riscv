
module UC (input logic clock, reset,
           input logic [6:0] opcode, // Opcode (Instr6_0) saido do Registrador de Instrucoes
                             estado,
           input logic [31:0] Instr31_0, // Instrucao inteira saida do Registrador de instrucoes
           output logic LoadIR, // Registrador de Instrucoes
                        PCWrite, // PC
                        WriteRegBanco, // Banco de Registradores
                        LoadRegA, // Registrador A
                        LoadRegB, // Registrador B
                        AluSrcA, // Mux1
                        AluSrcB, // Mux2
                        InstrType, // Seletor informando tipo da instrucao ao Signal Extend 
			AluFct, // Seletor da ALU
                        LoadMDR, // Registrador MDR 
                        MemToReg // Registrador do Mux3
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
	lui = 7'd10

	} state, nextState;


assign estado = state;

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
            		AluSrcA = 0; // NAO SETADO AINDA
            		AluSrcB = 0; // NAO SETADO AINDA
			nextState = busca;	
		end
		busca: begin
			PCWrite = 1; // Incrementa PC
			LoadIR = 0; // So no proximo ciclo
			WriteRegBanco = 0; // NAO SETADO AINDA
            		AluSrcA = 0; // NAO SETADO AINDA
            		AluSrcB = 0; // NAO SETADO AINDA
			nextState = salvaInstrucao;
		end
		salvaInstrucao: begin
			PCWrite = 0; // Incrementa PC
			LoadIR = 1; // So no proximo ciclo
			WriteRegBanco = 0; // NAO SETADO AINDA
            		AluSrcA = 0; // NAO SETADO AINDA
            		AluSrcB = 0; // NAO SETADO AINDA
			nextState = decodInstrucao;
		end
                decodInstrucao: begin
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
			//Inicializa todos os sinais
			LoadIR = 1;
			//PCWrite = 0
			WriteRegBanco = 1;
			LoadRegA = 1;
			LoadRegB = 1;
			//AluSrcA = 0
			//AluSrcB = 0
			//InstrType = 0
			AluFct = 3'b001;
			//LoadMDR = 0
			//MemToReg = 0
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




