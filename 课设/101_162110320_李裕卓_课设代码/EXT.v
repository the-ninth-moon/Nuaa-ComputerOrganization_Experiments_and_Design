`timescale 1ns / 1ns

module EXT_320 #(parameter len=16)
(
input [len-1:0] a,
input sign_ext,
output reg [31:0] b
);

always@(a) begin
  if(sign_ext==1&&a[len-1]) begin
	b=32'hffffffff;
    b[len-1:0] = a[len-1:0];
  end
  
  else begin
    b=32'h00000000;
    b[len-1:0] = a[len-1:0];
  end
  
end
endmodule
