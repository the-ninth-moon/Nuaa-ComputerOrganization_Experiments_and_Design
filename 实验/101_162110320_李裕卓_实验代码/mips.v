`timescale 1ns/1ns

module mips_320
(
input clk,
input rst
);

wire wren;
wire [31:0] dataAddress;
wire [31:0] writeData;
wire [31:0] instruction;
wire [31:0] readData;
wire [31:0] instructionAddress;
wire sb;
wire lb;
wire lbu;

CPU_320 cpu(clk,rst,instruction,readData,instructionAddress,wren,sb,lb,lbu,dataAddress,writeData);
InstructionMemory_320 inmem(instructionAddress,instruction);
DataMemory_320 datamem(clk,wren,sb,lb,lbu,dataAddress,writeData,readData);

endmodule