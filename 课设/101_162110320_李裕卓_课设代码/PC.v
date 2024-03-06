`timescale 1ns / 1ns

module PC_320(
input clk,
input [1:0] bubble,

input branch_id,
input [15:0]imm16_id,

input usebranch_mem,
input regReset,
input [5:0] branch_mem,
input [3:0] j_mem,
input zero_mem,
input sml_mem,
input [15:0] imm16_mem,
input [25:0] target_mem,
input [31:0] jumpRigister,
input [31:0] pcbefore,
input predict,
output reg [31:0] pc
);

//wire [31:0] pcOut;


//PC_320 pc(clk,pc,pcOut);
//InstructionMemory_320 inmem(pc,insturction);
wire [31:0] imm32_id;
wire [31:0] imm32_mem;
wire [31:0] pcAdd;

EXT_320 ext16_mem(imm16_mem,1'b1,imm32_mem);
EXT_320 ext16_id(imm16_id,1'b1,imm32_id);

initial begin
	pc=32'd0;
end

assign pcAdd=pc+4;

//计算下一条指令地址
always @(negedge clk && bubble==0 ) begin
	//pcAdd = pc + 32'd4;
	//$display("%b",useBranch);
	if(j_mem!=0) begin//j跳转
		if(j_mem[3]) begin
			pc={pcbefore[31:28],target_mem[25:0],2'b00};
			$display("--------jump goto %h--------",pc);
		end
		else if(j_mem[2]) begin
			pc={pcbefore[31:28],target_mem[25:0],2'b00};
			$display("--------jal goto %h--------",pc);
		end
		else if(j_mem[1]) begin
			pc=jumpRigister;
			$display("--------jr goto %h--------",pc);
		end
		else if(j_mem[0]) begin
			pc=jumpRigister;
			$display("--------jalr goto %h--------",pc);
		end
	end
	//预判正确，继续预测
	else begin
		if(predict&&branch_id) begin //预测要跳转:跳转信号为1且确实有跳转指令
			pc = pc + (imm32_id<<2) ;
			$display("--------predict goto %h----------",pc);
		end
		else begin//预测不要跳转
			pc = pcAdd;
			if(branch_id) begin
				$display("--------predict goto %h----------",pc);
			end
		end
	end


end
always @(posedge regReset && branch_mem) begin //错误了并且真有跳转指令，排除j型引起的
		//处理预判错误的
		//$display("!!!%d %d %d %d",pc,pcbefore,imm32_mem,pcbefore + (imm32_mem<<2));
	if(pc-32'd36 !=pcbefore + (imm32_mem<<2)&&usebranch_mem ) begin //需要跳转并且预测错了需要更新
		pc = pcbefore + (imm32_mem<<2);
		$display("--------handle wrong predict,should goto: %h--------",pc);
	end
	else begin
		pc = pcbefore+4;
		$display("--------handle wrong predict,should goto: %h--------",pc);
	end
end

    
endmodule
