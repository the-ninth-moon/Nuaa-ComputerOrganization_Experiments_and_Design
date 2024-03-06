`timescale 1ns/1ns

module top;

reg clk;
wire wren;
wire [31:0] dataAddress;
wire [31:0] writeData;
wire [31:0] instruction;
wire [31:0] readData;
wire [31:0] instructionAddress;
wire lb;
wire lbu;
wire sb;

pipeline_cpu cpu(
	.clk(clk),
 	.rst(1'b0),
	.instru_if(instruction),
	.data_in(readData),
	.instru_ifAddress(instructionAddress),
	.wren(wren),
	.dataAddress(dataAddress),
	.writeData(writeData),
	.lb(lb),
	.lbu(lbu),
	.sb(sb)
);

InstructionMemory_320 inmem(
	.address(instructionAddress),
	.instruction(instruction)
);

DataMemory_320 dm(
    .clk(clk),
    .wren(wren),
    .address(dataAddress),
    .writeData(writeData),
    .readData(readData),
	.lb(lb),
	.lbu(lbu),
	.sb(sb)
);

initial begin
	clk=1;
	#10;
end


always #5 clk=~clk;

// always @(instructionAddress) begin
// 	$display("%h",instruction);
// end


endmodule