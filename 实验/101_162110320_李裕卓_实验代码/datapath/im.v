`timescale 1ns / 1ns
module InstructionMemory_320(
input [31:0] address,
output [31:0] instruction
);
   
reg [31:0] RAM[1024-1:0];


initial begin
    $readmemh("code.txt",RAM,32'b00000000000000000000110000000000);
end
    
assign instruction=RAM[address[31:2]];

endmodule
