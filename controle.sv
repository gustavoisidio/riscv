module controle (input logic clock, reset,
				output logic [6:0] estado,
				output logic IMemRead, LoadIR, PCWrite
				);
				
enum logic [6:0] {busca = 7'b0, salvaInstrucao = 7'b1} state;
logic [6:0] nextState;
assing estado = state;

always_ff @(posedge clock, negedge reset) begin
	if (!reset) begin
		state <= busca;
    end else begin
		state <= nextState;
    end
end

always_comb begin
	case (state)
		busca: begin
			PCWrite = 1; // Incrementa PC
			IMemRead = 1;
			LoadIR = 0; // So no proximo ciclo
			nextState = salvaInstrucao;
		end
		salvaInstrucao: begin
			PCWrite = 0; // Incrementa PC
			IMemRead = 0;
			LoadIR = 1; // So no proximo ciclo
			nextState = busca;
		end
	endcase
end
				








endmodule:controle




