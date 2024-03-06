`timescale 1ns/1ns

module CPU_320(
input clk,
input reset,
//得到的信息
input [31:0] instruction,
input [31:0] data,
//给取指令部件
output [31:0] instructionAddress,
//给数据存储器
output wren,
output sb,
output lb,
output lbu,
output [31:0] dataAddress,
output [31:0] writeData
);

//PC-need
wire zero,sml;
wire [3:0] j;
wire [5:0] branch;
wire [15:0] imm16;
wire [25:0] jumpAddress;

//指令分段
wire [5:0] op;
wire [5:0] func;
wire [4:0] rs;
wire [4:0] rt;
wire [4:0] rd;
wire [4:0] rw;
wire [4:0] rw2;
wire [4:0] shamt;
wire [31:0] shamt_32;
assign op = instruction[31:26];
assign rs = instruction[25:21];
assign rt = instruction[20:16];
assign rd = instruction[15:11];
assign shamt = instruction[10:6];
assign func = instruction[5:0];
assign imm16 = instruction[15:0];
assign jumpAddress = instruction[25:0];

//解码
wire regDst,aluSrc,mem2Reg,regWr,memWr,extOp,rtype,link,useshamt;
wire [4:0] aluCtr;

wire overflow;

//传输
wire [31:0] busw;
wire [31:0] busw2;
wire [31:0] busa;
wire [31:0] busa2;
wire [31:0] busb;
wire [31:0] imm32;
wire [31:0] busb2;
wire [31:0] aluResult;
wire [31:0] storeRa;

Ctrl_320 decoder(
.op(op),
.func(func),
.clk(clk),
.branch(branch),
.j(j),
.link(link),
.lb(lb),
.lbu(lbu),
.sb(sb),
.useShamt(useshamt),
.regDst(regDst),
.mem2Reg(mem2Reg),
.regWr(regWr),
.memWr(memWr),
.extOp(extOp),
.rtype(rtype),
.aluSrc(aluSrc),
.aluCtr(aluCtr)
);

PC_320 pc(
.clk(clk),
.rst(reset),
.branch(branch),
.j(j),
.zero(zero),
.sml(sml),
.imm16(imm16),
.target(jumpAddress),
.jumpRigister(busa),
.pcAdd(storeRa),
.pc(instructionAddress)
);


//选择rd or rt作为rw
MUX21_320#(.len(5)) rd_rt(rt,rd,regDst,rw);
//是否要写到$ra中
MUX21_320#(.len(5)) rw_ra(rw,5'b11111,link,rw2);//链接时，写到$ra

//选择alu操作数
MUX21_320 busb_imm32(busb,imm32,aluSrc,busb2);
//选择alu结果 or 读出的数据
MUX21_320 alur_data(aluResult,data,mem2Reg,busw);
//是写pc+4到$ra还是busw到rw
MUX21_320 storeRa_busw(busw,storeRa,link,busw2);

//R型用不用shamt
MUX21_320 busa_shamt(busa,shamt_32,useshamt,busa2);
//MUX21_320 rt_shamt(busb2,shamt_32,useshamt,busb3);

RegFile_320 regfile(clk,reset,regWr&(~overflow),rs,rt,rw2,busw2,busa,busb);

EXT16_320 ext16(imm16,extOp,imm32);
EXT16_320#(.len(5)) extshamt(shamt,1'b0,shamt_32);



ALU_320 alu(busa2,busb2,aluCtr,aluResult,zero,sml,overflow);


//送给数据存储器
assign dataAddress = aluResult;
assign writeData = busb;
assign wren = memWr;

integer handle; 
initial begin
	handle = $fopen("cpu-out.txt","w");
end

wire useBranch;
assign useBranch = (branch[5]&&zero) | (branch[4]&&(~zero)) | (branch[3]&&((~sml)|zero)) | (branch[2]&&(~sml)&&(~zero)) | (branch[1]&&(sml|zero)) | (branch[0]&&sml);
//test
always @(negedge clk) begin
	//$display("CPU says busa is %d",busa);
	//$display("CPU says busa2 is %h",busa2);
	//$display("CPU says busb3 is %h",busb3);
	//$display("CPU says rs is %d",rs);
	//$display("CPU says rt is %d",rt);
	//$display("CPU says aluResult is %d",aluResult);
	//$display("CPU says aluCtr is %d",aluCtr);
	//$display("CPU says busb2 is %d",busb2);
	//$display("CPU says busb is %d",busb);
	//$display("CPU says imm16 is %d",imm16);
	//$display("CPU says imm32 is %d",imm32);
	//$display("CPU says regWr is %d",regWr);
	//$display("CPU says aluSrc is %d",aluSrc);
	//$display("CPU says wren is %d",wren);
	//$display("CPU says extOp is %d",extOp);
	//$display("CPU says jump is %d",jump);
	//$display("CPU says shamt is %d",shamt);
	//$display("CPU says shamt_32 is %d",shamt_32);
	//$display("CPU says regDst is %d",regDst);
	$fdisplay(handle,"PC:%h",instructionAddress);
	$fdisplay(handle,"instruction:%h",instruction);
	if(regWr&(~overflow)) $fdisplay(handle,"RegFile: write %h in %d",busw2,rw2);
	if(memWr&&(~sb)) $fdisplay(handle,"ROM: %h write in %h",writeData,dataAddress);
	if(memWr&&sb) $fdisplay(handle,"ROM: %h write in %h",writeData,dataAddress);
	$fdisplay(handle,"");
end

endmodule 
