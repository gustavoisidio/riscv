module mux5( Out,
                Sel,
                In0,
                In1,
                In2,
                In3,
                In4,
                In5,
                In6,
                In7); 

input [4:0]  In0,
             In1,
             In2,
             In3,
             In4,
             In5,
             In6,
             In7; 

input [2:0] Sel; // Seletor de 3 bits

output [4:0] Out; //The single 8-bit output line of the Mux 

reg [4:0] Out; 

always @ (In0 or In1 or In2 or In3 or In4 or In5 or In6 or In7 or Sel) begin 

            case (Sel) 

                3'b000 : Out = In0; 
                3'b001 : Out = In1; 
                3'b010 : Out = In2; 
                3'b011 : Out = In3; 
                3'b100 : Out = In4; 
                3'b101 : Out = In5; 
                3'b110 : Out = In6; 
                3'b111 : Out = In7; 

            endcase 
end  

endmodule
