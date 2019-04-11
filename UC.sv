
module UC (input logic clock, reset,
				output logic [6:0] estado,
				output logic LoadIR, PCWrite
				);
				
enum logic [6:0] {
	rst = 7'd0,
	busca = 7'd1,
	salvaInstrucao = 7'd2
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
			nextState = busca;	
		end
		busca: begin
			PCWrite = 1; // Incrementa PC
			LoadIR = 0; // So no proximo ciclo
			nextState = salvaInstrucao;
		end
		salvaInstrucao: begin
			PCWrite = 0; // Incrementa PC
			LoadIR = 1; // So no proximo ciclo
			nextState = busca;
		end
	endcase
end
				

endmodule:UC




