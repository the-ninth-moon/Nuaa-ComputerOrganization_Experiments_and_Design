`timescale 1ns / 1ns

module RegFile_320(
input clk,
input reset,
input we,
input [4:0] readAddress1,
input [4:0] readAddress2,
input [4:0] writeAddress,
input [31:0] writeData,
output [31:0] readData1,
output [31:0] readData2
);
	
reg [31:0] array_reg[31:0];

integer i;
initial begin
	for(i=0;i<=31;i=i+1) begin
		array_reg[i]=32'd0;
	end
end

always@(posedge clk,posedge reset) begin
  //$monitor("RegFile says radd1 is %d,  radd2 is %d",readAddress1,readAddress2);
  if(reset) begin
    i=0;
    while(i<32)
    begin
      array_reg[i]=0;
      i=i+1;
    end
  end
  
  else if(we) begin
    if(writeAddress!=0) begin
		array_reg[writeAddress]=writeData;
		$display("RegFile: write %h in %d",writeData,writeAddress);
	end
  end
  
  
  
end

assign readData1=array_reg[readAddress1];
assign readData2=array_reg[readAddress2];
assign ra = array_reg[31];

endmodule
