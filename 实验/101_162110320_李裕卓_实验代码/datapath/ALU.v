`timescale 1ns / 1ns

module ALU_320(
    input [31:0] a,
    input [31:0] b,
    input [4:0] op,
    output reg [31:0] out,
	output zero,
	output sml,
	output overflow
);

wire signed [31:0] a2;
wire signed [31:0] b2;

assign a2=a;
assign b2=b;


always @(*) begin
    case(op)
        5'b00000: out = a + b; 
        5'b00001: out = a - b; 
        5'b00010: out = a2 < b2?32'd1:32'd0; //slti
        5'b00011: out = a & b; 
        5'b00100: out = ~(a | b); 
        5'b00101: out = a | b; 
        5'b00110: out = a ^ b; 
		5'b00111: out = b << a;//sll-
		5'b01000: out = b >> a;//srl-
		5'b01001: out = a < b?32'd1:32'd0;//sltiu
		5'b01010: out = 0;//jalr pc+4
		5'b01011: out = 0;//jr $31
		5'b01100: out = b<<a;//sllv-
		5'b01101: out = b2>>>a;//sra -
		5'b01110: out = b2>>>a;//srav-
		5'b01111: out = b>>a;//srlv
		5'b10000: out = b<<16;//lui
		
        default: out = 32'h0000_0000; 
    endcase
end

assign zero= (out==32'd0) ? 1'b1:1'b0;
assign sml= out<0 ? 1'b1:1'b0;
assign overflow=(a[31]&b[31]&(~out[31])) | ((~a[31])&(~b[31])&out[31])&&(op==5'b00000);

endmodule
