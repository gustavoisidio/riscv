module UC (input logic clock, reset,
	   input logic [31:0] Instr31_0,
	   input logic InstrType,
	   output logic [63:0] outExtend  
           );

logic [11:0] immSB;
assign immSB = {Instr31_0[31],Instr[7],Instr[30:25],Instr[11:8]};

always_comb begin 

            case (InstrType)

		3'b000 : begin
			if(immSB[11] == 1'b1) begin
			 	outExtend  = {52'b1111111111111111111111111111111111111111111111111111,Instr31_0[31],Instr[7],Instr[30:25],Instr[11:8]}  // SB Extended
				outExtend  = {52'b1111111111111111111111111111111111111111111111111111,immSB}  // SB Extended
			end
		end
                3'b001 : outExtend  =  // S Extended
                3'b010 : outExtend  =  // I Extended
                3'b011 : outExtend  =  // I Extended
                3'b100 : outExtend  =  // I Extended

	    endcase

end


endmodule
