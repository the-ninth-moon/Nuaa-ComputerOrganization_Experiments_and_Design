`timescale 1ns / 1ns

module PC_320(
input clk,
input rst,
input [5:0] branch,
input [3:0] j,
input zero,
input sml,
input [15:0] imm16,
input [25:0] target,
input [31:0] jumpRigister,

output [31:0] pcAdd,
output reg [31:0] pc
);

//wire [31:0] pcOut;


//PC_320 pc(clk,pc,pcOut);
//InstructionMemory_320 inmem(pc,insturction);

wire [31:0] imm32;

EXT16_320 ext16(imm16,1'b1,imm32);

initial begin
	pc=32'h0000_3000;
end

assign pcAdd=pc+4;

wire useBranch;
assign useBranch = (branch[5]&&zero) | (branch[4]&&(~zero)) | (branch[3]&&((~sml)|zero)) | (branch[2]&&(~sml)&&(~zero)) | (branch[1]&&(sml|zero)) | (branch[0]&&sml);

//计算下一条指令地址
always @(posedge clk) begin
	//pcAdd = pc + 32'd4;
	//$display("%b",useBranch);
	if(rst) begin
		pc=32'h00003000;
	end
	if(j!=0) begin//j跳转
		if(j[3]) begin
			pc={pc[31:28],target[25:0],2'b00}+32'h0000_3000;
			$display("jump goto %h",pc);
		end
		else if(j[2]) begin
			pc={pc[31:28],target[25:0],2'b00}+32'h0000_3000;
			$display("jal goto %h",pc);
		end
		else if(j[1]) begin
			pc=jumpRigister+32'h0000_3000;
			$display("jr goto %h",pc);
		end
		else if(j[0]) begin
			pc=jumpRigister+32'h0000_3000;
			$display("jalr goto %h",pc);
		end
	end
	else begin//条件跳转
		if(useBranch) begin
			pc = pc + (imm32<<2);
			$display("branch goto %h",pc);
		end
		else begin//普通
			pc = pcAdd;
		end
	end
end

    
endmodule
