module extendToI (	input logic clock, reset,
                    input logic [3:0] InstrIType, // Indicador do tipo da instrucao
                    input logic [63:0]  DataMemOut, // Saida da memoria de dados
                                        outMDR, // Saida da memoria de dados depois de MDR
                                        regBOut, // rs2 Vindo do Reg B
                    output logic [63:0] extendToMem,
                                        extendToBanco
);

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
        4'b0110 : begin 
        
        end
        4'b0111 : begin
        
        end
        default: begin
            extendToMem = regBOut;
        end
    endcase
end
endmodule




