module MUX31_320 #(parameter len=32)
(
input [len-1:0] a,
input [len-1:0] b,
input [len-1:0] c,
input [1:0] select,
output reg [len-1:0] r
);
	
always @(*) begin
    case(select)
      2'b00:
        r=a;
      2'b01:
        r=b;
	  2'b10:
	    r=c;
    endcase
	
end

endmodule