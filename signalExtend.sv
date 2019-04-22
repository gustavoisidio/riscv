module signalExtend (	input logic clock, reset,
						input logic [31:0] Instr31_0,
						input logic [2:0] InstrType,
						output logic [63:0] outExtend  
					);

logic [11:0] immI, immS, immSB;
logic [20:0] immUJ, immU;

assign immI = Instr31_0[31:20];
assign immS = {Instr31_0[31:25],Instr31_0[11:7]};
assign immSB = {Instr31_0[31], Instr31_0[7], Instr31_0[30:25], Instr31_0[11:8]};
assign immUJ = {Instr31_0[31], Instr31_0[19:12], Instr31_0[20], Instr31_0[30:21]};
assign immU = Instr31_0[31:12];


always_comb begin 

		case (InstrType)

			3'b000 : begin
				if(immI[11] == 1'b1) begin
					//outExtend  = {52'b1111111111111111111111111111111111111111111111111111,Instr31_0[31],Instr[7],Instr[30:25],Instr[11:8]}  // SB Extended
					outExtend  = {52'b1111111111111111111111111111111111111111111111111111,immI};  // I Extended
				end
				else begin
					outExtend  = {52'b0000000000000000000000000000000000000000000000000000,immI};  // I Extended
				end
			end
			3'b001 : begin
				if(immI[11] == 1'b1) begin
					outExtend  = {52'b1111111111111111111111111111111111111111111111111111,immS};  // S Extended
				end
				else begin
					outExtend  = {52'b0000000000000000000000000000000000000000000000000000,immS};  // S Extended
				end
			end
			3'b010 : begin
				if(immI[11] == 1'b1) begin
					outExtend  = {52'b1111111111111111111111111111111111111111111111111111,immSB};  // SB Extended
				end
				else begin
					outExtend  = {52'b0000000000000000000000000000000000000000000000000000,immSB};  // SB Extended
				end
			end
			3'b011 : begin
				if(immI[11] == 1'b1) begin
					outExtend  = {43'b1111111111111111111111111111111111111111111,immUJ};  // UJ Extended
				end
				else begin
					outExtend  = {43'b0000000000000000000000000000000000000000000,immUJ};  // UJ Extended
				end
			end
			3'b100 : begin
				if(immI[11] == 1'b1) begin
					outExtend  = {43'b1111111111111111111111111111111111111111111,immU};  // U Extended
				end
				else begin
					outExtend  = {43'b0000000000000000000000000000000000000000000,immU};  // U Extended
				end
			end
			3'b101 : begin // Beq ou Bne
				
			end

	    endcase

end


endmodule
