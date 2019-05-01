module extendToPC (	input logic clock, reset,
                    input logic [31:0] InstMemOut,
                    output logic [63:0] outExtendToPC  
);

// [31:24] Sao os 8 bits mais significativos

assign outExtendToPC = {56'd0, InstMemOut[7:0]};

endmodule

