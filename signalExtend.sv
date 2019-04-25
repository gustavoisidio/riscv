module signalExtend (	input logic clock, reset,
						input logic [31:0] Instr31_0,
						input logic [2:0] InstrType,
						output logic [63:0] outExtend  
					);

logic [11:0] immI, immS, immSB;
logic [19:0] immUJ, immU;

assign immI = Instr31_0[31:20];
assign immS = {Instr31_0[31:25],Instr31_0[11:7]};
assign immSB = {Instr31_0[31], Instr31_0[7], Instr31_0[30:25], Instr31_0[11:8]};
assign immUJ = {Instr31_0[31], Instr31_0[19:12], Instr31_0[20], Instr31_0[30:21]};
assign immU = Instr31_0[31:12];

always_comb begin 

		case (InstrType)

			3'b000 : begin
				if(immI[11] == 1'b1) begin
					outExtend  = {52'b1111111111111111111111111111111111111111111111111111,immI};  // I Extended
				end
				else begin
					outExtend  = {52'b0000000000000000000000000000000000000000000000000000,immI};  // I Extended
				end
			end
			3'b001 : begin
				if(immS[11] == 1'b1) begin
					outExtend  = {52'b1111111111111111111111111111111111111111111111111111,immS};  // S Extended
				end
				else begin
					outExtend  = {52'b0000000000000000000000000000000000000000000000000000,immS};  // S Extended
				end
			end
			3'b010 : begin
				if(immSB[11] == 1'b1) begin
					outExtend = {50'b11111111111111111111111111111111111111111111111111, immSB, 2'b00}; // SB Extended
				end
				else begin
					outExtend  = {50'b00000000000000000000000000000000000000000000000000,immSB,2'b00};  // SB Extended
				end
			end
			3'b011 : begin // JAL
				if(immUJ[19] == 1'b1) begin
					outExtend  = {42'b111111111111111111111111111111111111111111,immUJ, 2'b00};  // UJ Extended
				end
				else begin
					outExtend  = {42'b000000000000000000000000000000000000000000,immUJ, 2'b00};  // UJ Extended
				end
			end
            3'b100 : begin             
				if(immU[19] == 1'b1) begin
					outExtend  = {32'b11111111111111111111111111111111,immU, 12'b0};  // U Extended
				end
				else begin
					outExtend  = {32'b00000000000000000000000000000000,immU, 12'b0};  // U Extended
				end
			end

	    endcase

end

endmodule
