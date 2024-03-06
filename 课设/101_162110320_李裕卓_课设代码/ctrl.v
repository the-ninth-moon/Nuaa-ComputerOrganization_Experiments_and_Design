`timescale 1ns / 1ns

module Ctrl_320(
input [5:0] op,
input [5:0] func,
input clk,
input regReset,//控制冒险，有一条指令if已经被读入，要让它死无葬身之地
output [5:0] branch,
output [3:0] j,
output link,//是不是jlink
output lw,
output lb,
output lbu,
output sb,
output useShamt,
output regDst,
output mem2Reg,
output regWr,
output memWr,
output extOp,
output rtype,
output aluSrc,
output reg [4:0] aluCtr
);

//PLA，R型，I型，J型
assign rtype = (op==6'b000000);  
assign useShamt = rtype&&((func==6'b000000)||(func==6'b000010)||(func==6'b000011));

//处理所有类似beq的 done
wire beq,bne,bgez,bgtz,blez,bltz;
assign beq   = (op==6'b000100); //全是减法，rt规定了
assign bne   = (op==6'b000101); 
assign bgez  = (op==6'b000001);
assign bgtz  = (op==6'b000111);
assign blez  = (op==6'b000110);
assign bltz  = (op==6'b000001);
assign branch = {beq,bne,bgez,bgtz,blez,bltz};

//处理类似jump的
assign jump  = (op==6'b000010);
assign jal = (op==6'b000011);
assign jr = (func==6'b001000)&&rtype;
assign jalr = (func==6'b001001)&&rtype;
assign j={jump,jal,jr,jalr};
assign link = jal|jalr;

//所有剩下的
wire addiu,sw,lui,slti,sltiu,andi,oir,xori;
assign addiu=(op==6'b001001);
assign lw=(op==6'b100011);
assign sw=(op==6'b101011);
assign lui=(op==6'b001111);
assign slti=(op==6'b001010);
assign sltiu=(op==6'b001011);
assign lb=(op==6'b100000);
assign lbu=(op==6'b100100);
assign sb=(op==6'b101000);
assign andi=(op==6'b001100);
assign ori=(op==6'b001101);
assign xori=(op==6'b001110);


//传出去的控制信号
assign regDst = rtype;
assign aluSrc = addiu || lw || sw || lui || slti || sltiu || lb || lbu || sb || andi || ori || xori;
assign mem2Reg = lw || lb || lbu;
assign regWr = regReset? 0 :rtype || addiu || lw || lui || slti || sltiu || lb ||lbu ||andi ||ori || xori || jal;
assign memWr = regReset? 0 :sw || sb;
assign extOp = addiu || lw ||sw || slti || lb || lbu ||sb ||sltiu;

//分配ALU操作,I型，J型 
wire [5:0] aluOp;
assign aluOp[0] = beq || bne || sltiu || bgez ||bgtz ||blez || bltz ||andi ||ori;
assign aluOp[1] = slti || andi || xori || jal;
assign aluOp[2] = ori || xori;
assign aluOp[3] = sltiu || jal;
assign aluOp[4] = lui;

always @(*) begin
	if(rtype) begin //所有R型指令
		if(func==6'b100001) 	 aluCtr=5'b00000;
		else if(func==6'b100011) aluCtr=5'b00001;
		else if(func==6'b101010) aluCtr=5'b00010;
		else if(func==6'b100100) aluCtr=5'b00011;
		else if(func==6'b100111) aluCtr=5'b00100;
		else if(func==6'b100101) aluCtr=5'b00101;
		else if(func==6'b100110) aluCtr=5'b00110;
		else if(func==6'b000000) aluCtr=5'b00111;
		else if(func==6'b000010) aluCtr=5'b01000;
		else if(func==6'b101011) aluCtr=5'b01001;
		else if(func==6'b001001) aluCtr=5'b01010;
		else if(func==6'b001000) aluCtr=5'b01011;
		else if(func==6'b000100) aluCtr=5'b01100;
		else if(func==6'b000011) aluCtr=5'b01101;
		else if(func==6'b000111) aluCtr=5'b01110;
		else if(func==6'b000110) aluCtr=5'b01111;
		else ;
	end
	else begin
		aluCtr = aluOp;
	end
end

endmodule