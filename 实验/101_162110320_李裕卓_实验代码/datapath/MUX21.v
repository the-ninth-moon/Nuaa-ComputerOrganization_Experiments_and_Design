module MUX21_320 #(parameter len=32)
(
input [len-1:0] a,
input [len-1:0] b,
input select,
output reg [len-1:0] r
);
	
always @(*) begin
    case(select)
      1'b0:
        r=a;
      1'b1:
        r=b;
    endcase
	
end

endmodule