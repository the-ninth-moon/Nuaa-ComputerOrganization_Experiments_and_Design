`timescale 1ns/1ns

module top_320;
reg clk,rst;

initial begin
	clk=0;
	rst=0;
end

always #5 clk=~clk;

mips_320 mips(clk,rst);

endmodule