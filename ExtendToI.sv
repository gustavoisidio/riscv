module extendToI (	input logic clock, reset,
                    input logic [3:0] InstrIType, // Indicador do tipo da instrucao
                    input logic [31:0] Instr31_0,
                    input logic [63:0]  DataMemOut, // Saida da memoria de dados
                                        outMDR, // Saida da memoria de dados depois de MDR
                                        regBOut, // rs2 Vindo do Reg B
                                        regAOut, // rs1 Vindo do Reg A
                    output logic [63:0] extendToMem,
                                        extendToBanco
);

wire logic [5:0] shamt;
assign shamt = Instr31_0[25:20];

always_comb begin 

    case (InstrIType)
        4'b0000 : begin // lb
            if(DataMemOut[7] == 1'b1) begin
                extendToBanco = {56'b11111111111111111111111111111111111111111111111111111111, DataMemOut[7:0]};
            end
            else begin
                extendToBanco = {56'd0, DataMemOut[7:0]};
            end
        end
        4'b0001 : begin // lh
            if(DataMemOut[15] == 1'b1) begin
                extendToBanco = {53'b11111111111111111111111111111111111111111111111111111, DataMemOut[15:0]};
            end
            else begin
                extendToBanco = {53'd0, DataMemOut[15:0]};
            end
        end
        4'b0010 : begin // lw
            if(DataMemOut[31] == 1'b1) begin
                extendToBanco = {32'b11111111111111111111111111111111, DataMemOut[31:0]};
            end
            else begin
                extendToBanco = {32'd0, DataMemOut[31:0]};
            end
        end
        4'b0011 : begin // lbu
            extendToBanco = {56'd0, DataMemOut[7:0]};
        end
        4'b0100 : begin // lhu
            extendToBanco = {53'd0, DataMemOut[15:0]};
        end
        4'b0101 : begin // lwu
            extendToBanco = {32'd0, DataMemOut[31:0]};
        end
        4'b0110 : begin // sd
            extendToMem = regBOut;
        end
        4'b0111 : begin // sw
            extendToMem = {DataMemOut[63:32],regBOut[31:0]};
        end
        4'b1000 : begin // sh
            extendToMem = {DataMemOut[63:16],regBOut[15:0]};
        end
        4'b1001 : begin // sb
            extendToMem = {DataMemOut[63:8],regBOut[7:0]};
        end
        4'b1010 : begin // ld
            extendToBanco = DataMemOut[63:0];
        end
        4'b1011: begin // slli
            extendToBanco = regAOut << shamt;
        end
        4'b1100 : begin // srli
            extendToBanco = regAOut >> shamt;
        end
        4'b1101 : begin // srai
            extendToBanco = regAOut >>> shamt;
        end
        4'b1110 : begin 
            
        end
        4'b1111 : begin 
            
        end
        default: begin
            
        end
    endcase
end
endmodule




