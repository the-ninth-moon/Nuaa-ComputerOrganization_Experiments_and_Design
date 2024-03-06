`timescale 1ns / 1ns

module DataMemory_320(
input clk,

input wren,
input sb,//store byte
input lb,//load byte
input lbu,
input [31:0] address,
input [31:0] writeData,
output [31:0] readData
);

//小端方式

//reg [8:0] ROM [4294967296-1:0];
reg [7:0] ROM [1024*4-1:0];
wire[31:0] ROM20;
assign ROM20={ROM[23],ROM[22],ROM[21],ROM[20]};
initial begin
  $readmemh("data.txt",ROM);
end

always @(negedge clk) begin
    if(wren) begin
		if(sb) begin
			//ROM[address[31:2]]={writeData[7:0],ROM[address[31:2]][23:0]};
			//确定是那个字节
			ROM[address]=writeData[7:0];
			$display("ROM: %h writebyte in %h",{ ROM[address[31:2]*4+3] , ROM[address[31:2]*4+2] , ROM[address[31:2]*4+1],ROM[address[31:2]*4] },{address[31:2], 2'b00} );
		end
		else begin
		//最高有效位放最高
			{ ROM[address+3],ROM[address+2],ROM[address+1],ROM[address] }=writeData;
			$display("ROM: %h write in %h",writeData,address);
		end
	 end
end

assign readData= address<32'd4096 ? (lb||lbu)?(lb?{ { 24{ROM[address][7]} },ROM[address]}:{ 24'd0,ROM[address]}):({ ROM[address+3], ROM[address+2], ROM[address+1], ROM[address] }) : 0 ;


endmodule
