module pipeline_cpu(
 input clk,
 input rst,
//得到的信息
 input [31:0] instru_if,
 input [31:0] data_in,
//给取指令部件
 output [31:0] instru_ifAddress,
//给数据存储器
 output wren,
 output sb,
 output lb,
 output lbu,
 output [31:0] dataAddress,
 output [31:0] writeData
);



wire[1:0] bubble;


//准备连线，
wire[31:0] instru_id;       
wire[31:0] instru_idAddress;
wire[31:0] instru_exAddress;
wire[31:0] instru_memAddress;     
wire[31:0] instru_wrAddress;    
wire [5:0] branch_id;            
wire [3:0] j_id;    
wire   regDst_id;           
wire   aluSrc_id;
wire   link_id;
wire lw_id;
wire   lb_id;
wire   lbu_id;
wire   sb_id;
wire   useshamt_id;           
wire[4:0] aluCtr_id;           
wire   mem2Reg_id;             
wire   regWr_id;            
wire   memWr_id;            
wire   extOp_id;         

wire[31:0]   busA_id;            //Reg[Rs]      
wire[31:0]   busB_id;            //Reg[Rt]   
wire[15:0]   imm16_id;           //输入imm16 
wire[4:0]    rt_id;              
wire[4:0]    rd_id;  

wire [5:0] branch_ex;           
wire [3:0] j_ex;    
wire regDst_ex;           
wire aluSrc_ex;   
wire   link_ex;
wire lw_ex;
wire   lb_ex;
wire   lbu_ex;
wire   sb_ex;
wire   useshamt_ex;          
wire[4:0]  aluCtr_ex;           
wire mem2Reg_ex;             
wire regWr_ex;            
wire memWr_ex;            
wire extOp_ex;       

wire[31:0] busA_ex;            //Reg[Rs]      
wire[31:0] busB_ex;            //Reg[Rt]        
wire[15:0] imm16_ex;   
wire[4:0]  rs_ex;                
wire[4:0]  rt_ex;              
wire[4:0]  rd_ex;  
wire overflow_ex;//给pc
wire zero_ex;//给pc
wire sml_ex;//给pc
wire[31:0] aluResult_ex;//mem address

wire link_mem;
wire [5:0] branch_mem;   //控制信号传递
wire zero_mem;    
wire  overflow_mem;
wire sml_mem;    
wire [3:0]j_mem;          
wire mem2Reg_mem;             
wire regWr_mem;            
wire memWr_mem;      
wire   lb_mem;
wire   lbu_mem;
wire   sb_mem;                     

wire [31:0] aluResult_mem;
wire [31:0] busB_mem;   
wire[31:0] busA_mem;

wire link_wr;
wire mem2Reg_wr;
wire regWr_wr;
wire overflow_wr;
wire[31:0] aluResult_wr;//用于最终写回寄存器
wire[31:0] data_out;
wire[15:0] imm16_mem;//计算跳转
wire[25:0] jumpAddress_id;
wire[25:0] jumpAddress_ex;
wire[25:0] jumpAddress_mem;
wire [31:0] busw;

wire [4:0] rw_ex;
wire [4:0] rw_wr;//用于最终写回
wire [4:0] rw_mem;

wire [4:0] rt_mem;//留着用于辨别sw指令选择aluresult还是busb
wire regReset;//处理jump和branch的控制冒险

wire usebranch_mem;
assign usebranch_mem = (branch_mem[5]&&zero_mem) | (branch_mem[4]&&(~zero_mem)) | (branch_mem[3]&&((~sml_mem)|zero_mem)) | (branch_mem[2]&&(~sml_mem)&&(~zero_mem)) | (branch_mem[1]&&(sml_mem|zero_mem)) | (branch_mem[0]&&sml_mem);

wire predict;

//预测是否跳转
predict_320 pre(
    .clk(clk),
    .branch_mem(branch_mem),
    .usebranch_mem(usebranch_mem),
    .predict(predict),
    .predict_new(predict)
);

wire branch_if;
wire [5:0] tmp;
assign tmp = instru_if[31:26];
assign branch_if = (tmp==6'b000100) || (tmp==6'b000101) || (tmp==6'b000001) || (tmp==6'b000111) || (tmp==6'b000110);  


//开始取指令
PC_320 pc(
    .clk(clk),
    .bubble(bubble),
    .regReset(regReset),
    .branch_id(branch_if),
    .imm16_id(instru_if[15:0]),
    .usebranch_mem(usebranch_mem),
    .branch_mem(branch_mem),
    .j_mem(j_mem),
    .zero_mem(zero_mem),
    .sml_mem(sml_mem),
    .imm16_mem(imm16_mem),
    .target_mem(jumpAddress_mem),
    .jumpRigister(busA_mem),
    .pcbefore(instru_memAddress),
    .predict(predict),
    .pc(instru_ifAddress)
);

//传递给IF/ID
IFIDReg_320 ifidreg(
    .clk(clk),
    .regReset(regReset),
    .bubble(bubble),
    .instru_if(instru_if),//由im给出的
    .instru_id(instru_id),
    .instru_ifAddress(instru_ifAddress),
    .instru_idAddress(instru_idAddress)
);


//指令分段
wire [5:0] op;
wire [5:0] func;
wire [4:0] rs;

wire [4:0] shamt;
wire [4:0] shamt_ex;
assign op = instru_id[31:26];
assign rs = instru_id[25:21];
assign rt_id = instru_id[20:16];
assign rd_id = instru_id[15:11];
assign shamt = instru_id[10:6];
assign func = instru_id[5:0];
assign imm16_id = instru_id[15:0];
assign jumpAddress_id = instru_id[25:0];
//译码
//wire regDst_id,aluSrc,mem2Reg,regWr,memWr,extOp,rtype;
//wire [2:0] aluCtr;
Ctrl_320 decode(
    .op(op),
    .func(func),
    .clk(clk),
    .branch(branch_id),
    .j(j_id),
    .regReset(regReset),
    .link(link_id),
    .lw(lw_id),
    .lb(lb_id),
    .lbu(lbu_id),
    .sb(sb_id),
    .useShamt(useshamt_id),
    .regDst(regDst_id),
    .mem2Reg(mem2Reg_id),
    .regWr(regWr_id),
    .memWr(memWr_id),
    .extOp(extOp_id),
    .rtype(rtype_id),
    .aluSrc(aluSrc_id),
    .aluCtr(aluCtr_id)
);

//给regfile取数
RegFile_320 regfile(
    .clk(clk),
    .reset(rst),
    .we(regWr_wr&&(~overflow_wr)),
    .readAddress1(rs),
    .readAddress2(rt_id),
    .writeAddress(rw_wr),//wr段给出
    .writeData(busw),//wr段给出
    .readData1(busA_id),
    .readData2(busB_id)
);

//ID/EX段
IDEXReg_320 idexreg(
    .clk(clk),
    .regReset(regReset),
    .bubble(bubble),
    .branch_id(branch_id),
    .j_id(j_id),
    .regDst_id(regDst_id),
    .aluSrc_id(aluSrc_id),
    .link_id(link_id),
    .lw_id(lw_id),
    .lb_id(lb_id),
    .lbu_id(lbu_id),
    .sb_id(sb_id),
    .useshamt_id(useshamt_id),
    .aluCtr_id(aluCtr_id),
    .mem2Reg_id(mem2Reg_id),
    .regWr_id(regWr_id),
    .memWr_id(memWr_id),
    .extOp_id(extOp_id),
    .rtype_id(rtype_id),

    .busA_id(busA_id),                  
    .busB_id(busB_id),   
    .shamt_id(shamt),            
    .imm16_id(imm16_id),           
    .jumpAddress_id(jumpAddress_id),
    .rt_id(rt_id), 
    .rs_id(rs),             
    .rd_id(rd_id),  
    .instru_idAddress(instru_idAddress),

    //控制信号输出
    .branch_ex(branch_ex),           
    .j_ex(j_ex),    
    .regDst_ex(regDst_ex),  
    .link_ex(link_ex),
    .lw_ex(lw_ex),
    .lb_ex(lb_ex),
    .lbu_ex(lbu_ex),
    .sb_ex(sb_ex),
    .useshamt_ex(useshamt_ex),         
    .aluSrc_ex(aluSrc_ex),           
    .aluCtr_ex(aluCtr_ex),           
    .mem2Reg_ex(mem2Reg_ex),             
    .regWr_ex(regWr_ex),            
    .memWr_ex(memWr_ex),            
    .extOp_ex(extOp_ex),            
    .rtype_ex(rtype_ex),         

    //数据输出  
    .busA_ex(busA_ex),            //Reg[Rs]      
    .busB_ex(busB_ex),            //Reg[Rt]       
    .shamt_ex(shamt_ex), 
    .imm16_ex(imm16_ex), 
    .jumpAddress_ex(jumpAddress_ex),                 
    .rs_ex(rs_ex),      
    .rt_ex(rt_ex),          
    .rd_ex(rd_ex),
    .instru_exAddress(instru_exAddress)
);
//处理loaduse
load_use320 lu(
    .clk(clk),
    .lw_ex(lw_ex),
    .lb_ex(lb_ex),
    .lbu_ex(lbu_ex),
    .rs_id(rs),
    .rt_id(rt_id),
    .rt_ex(rt_ex),
    .j_mem(j_mem),
    .usebranch_mem(usebranch_mem),
    .bubble(bubble),
    .bubble_new(bubble)
);

//EX阶段

Control_hazar320 jumpBranch(
    .clk(clk),
    .j_mem(j_mem),
    .usebranch_mem(usebranch_mem),
    .branch_mem(branch_mem),
    .predict(predict),
    .regReset(regReset)
);

wire [4:0] rw_rdrt;
//给出rw 选择rd还是rt
MUX21_320 rt_rd(rt_ex,rd_ex,regDst_ex,rw_rdrt);
//是否要写到$ra中
MUX21_320#(.len(5)) rw_ra(rw_rdrt,5'b11111,link_ex,rw_ex);//链接时，写到$ra

//为alu做准备
wire [31:0] imm32;
wire [31:0] shamt_32;
wire [31:0] busb_imm32;
wire [31:0] busa_shamt;

//不转发所使用的数据B
EXT_320 ext16(imm16_ex,extOp_ex,imm32);
MUX21_320 busB_imm16(busB_ex,imm32,aluSrc_ex,busb_imm32);
//不转发所使用的数据A
EXT_320#(.len(5)) extshamt(shamt_ex,1'b0,shamt_32);
MUX21_320 busA_shamt(busA_ex,shamt_32,useshamt_ex,busa_shamt);

wire[31:0] aluA;
wire[31:0] aluB;
wire[1:0] aluAchoose;
wire[1:0] aluBchoose;
Forwarding_Unit_302 forward(
    .rw_mem(rw_mem),       
    .rw_wr(rw_wr),      
    .rs_ex(rs_ex),              
    .rt_ex(rt_ex),           
    .aluSrc_ex(aluSrc_ex), 
    .regWr_mem(regWr_mem),           
    .regWr_wr(regWr_wr),    
    .mem2Reg_wr(mem2Reg_wr),   
    .bubble(bubble),            
    .aluAchoose(aluAchoose),              
    .aluBchoose(aluBchoose)
);

MUX41_320 toalua(busa_shamt,aluResult_mem,aluResult_wr,data_in,aluAchoose,aluA);
MUX41_320 toalub(busb_imm32,aluResult_mem,aluResult_wr,data_in,aluBchoose,aluB);

ALU_320 alu(
    .clk(clk),
    .a(aluA),
    .b(aluB),
    .op(aluCtr_ex),
    .out(aluResult_ex),
	.zero(zero_ex),
	.sml(sml_ex),
	.overflow(overflow_ex)
);



//EXMEM reg
EXMEMReg_320 exmemreg(
    .clk(clk),              
    .regReset(regReset),
    .branch_ex(branch_ex),           
    .j_ex(j_ex),    
    .mem2Reg_ex(mem2Reg_ex),//选择busw时要用             
    .regWr_ex(regWr_ex), //写寄存器要用           
    .memWr_ex(memWr_ex), //mem用                               
    .overflow_ex(overflow_ex),//给pc
	.zero_ex(zero_ex),//给pc
    .sml_ex(sml_ex),
	.aluResult_ex(aluResult_ex),//mem address
	.busB_ex(busB_ex),//mem datain
    .busA_ex(aluA),//要接受转发过的
    .imm16_ex(imm16_ex),
    .jumpAddress_ex(jumpAddress_ex), 
    .rt_ex(rt_ex),
    .rw_ex(rw_ex),
    .lb_ex(lb_ex),
    .lbu_ex(lbu_ex),
    .sb_ex(sb_ex),
    .link_ex(link_ex),

    .branch_mem(branch_mem),           
    .j_mem(j_mem),          
    .mem2Reg_mem(mem2Reg_mem),             
    .regWr_mem(regWr_mem),            
    .memWr_mem(memWr_mem),                    
    .overflow_mem(overflow_mem),
	.zero_mem(zero_mem),
    .sml_mem(sml_mem),
	.aluResult_mem(aluResult_mem),
    .imm16_mem(imm16_mem),
    .jumpAddress_mem(jumpAddress_mem),
    .busB_mem(busB_mem),  
    .busA_mem(busA_mem),
    .rw_mem(rw_mem),
    .rt_mem(rt_mem),
    .lb_mem(lb_mem),
    .lbu_mem(lbu_mem),
    .sb_mem(sb_mem),
    .link_mem(link_mem),

    .instru_exAddress(instru_exAddress),
    .instru_memAddress(instru_memAddress)
);

//送给数据存储器
assign wren = memWr_mem;
assign dataAddress = aluResult_mem;
MUX21_320 realData(busB_mem,aluResult_wr, rt_mem == rw_wr ,writeData);
assign sb=sb_mem;
assign lb=lb_mem;
assign lbu=lbu_mem;

//MEM WR Reg
MEMWRReg_320 memwrreg(
    .clk(clk),               
    .regReset(regReset),
    .mem2Reg_mem(mem2Reg_mem),             
    .regWr_mem(regWr_mem),                                            
    .overflow_mem(overflow_mem),
	.aluResult_mem(aluResult_mem),
	.data_in(data_in),
    .rw_mem(rw_mem),  
    .mem2Reg_wr(mem2Reg_wr),             
    .regWr_wr(regWr_wr),                     
    .overflow_wr(overflow_wr),
	.aluResult_wr(aluResult_wr),
	.data_out(data_out), 
    .rw_wr(rw_wr),
    .link_mem(link_mem),
    .link_wr(link_wr),
    .instru_memAddress(instru_memAddress),
    .instru_wrAddress(instru_wrAddress)
);
//准备写回寄存器

wire [31:0] busw_nlink;
MUX21_320 alure_dataout(aluResult_wr,data_out,mem2Reg_wr,busw_nlink);
MUX21_320 storeRa_busw(busw_nlink,instru_wrAddress+4,link_wr,busw);

integer handle; 
initial begin
	handle = $fopen("pipeline-cpu-out.txt","w");
end

always @(negedge clk) begin
	$fdisplay(handle,"PC_id:%h",instru_idAddress);
	$fdisplay(handle,"instruction:%h",instru_id);
	if(regWr_wr&(~overflow_wr)) $fdisplay(handle,"RegFile: write %h in %d",busw,rw_wr);
	if(memWr_mem&&(~sb_mem)) $fdisplay(handle,"ROM: %h write in %h",writeData,dataAddress);
	if(memWr_mem&&sb_mem) $fdisplay(handle,"ROM: %h write in %h",writeData,dataAddress);
	$fdisplay(handle,"");
end

endmodule