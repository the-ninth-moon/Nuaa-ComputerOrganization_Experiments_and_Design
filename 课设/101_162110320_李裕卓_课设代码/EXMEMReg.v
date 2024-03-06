module EXMEMReg_320(
    input           clk,                //时钟信号输入
    input    regReset,

    //控制信号输入
    input[5:0]  branch_ex,           
    input[3:0]  j_ex,    
    input mem2Reg_ex,//选择busw时要用             
    input regWr_ex, //写寄存器要用           
    input memWr_ex, //mem用     
    input lbu_ex,
    input lb_ex,
    input sb_ex,
    input link_ex,
    //input  rtype_ex,                           
    
    //数据输入     
    input	overflow_ex,//给pc
	input	zero_ex,//给pc
    input   sml_ex,
    input [31:0] busA_ex,
	input[31:0]	 aluResult_ex,//mem address
	input[31:0]  busB_ex,//mem datain
    input[15:0]  imm16_ex,
    input[25:0]  jumpAddress_ex, 
    input[4:0]   rt_ex,
    input[4:0]   rw_ex,
    input[31:0]  instru_exAddress,
	
	

    //控制信号输出
    output reg [5:0] branch_mem,           
    output reg [3:0] j_mem,          
    output reg  mem2Reg_mem,             
    output reg  regWr_mem,            
    output reg  memWr_mem,     
    output reg lb_mem,
    output reg lbu_mem,
    output reg sb_mem,  
    output reg link_mem,//jal指令没有给rt设置传到之后有用            
    output reg overflow_mem,
	output reg zero_mem,
    output reg sml_mem,
    //数据输出  
	output reg[31:0] aluResult_mem,
    output reg[15:0] imm16_mem,
    output reg[25:0] jumpAddress_mem,
	output reg[31:0] busB_mem,  
    output reg[31:0] busA_mem,
    output reg[4:0]  rt_mem,
    output reg[4:0]  rw_mem,
    output reg[31:0] instru_memAddress//写给31号寄存器要用到之前的指令地址
);
initial begin
    branch_mem=0;           
    j_mem=0;           
    mem2Reg_mem=0;               
    regWr_mem=0;              
    memWr_mem=0;                     
    overflow_mem=0;  
	zero_mem=0;  
	aluResult_mem=32'd0;  
    imm16_mem=16'd0;  
    jumpAddress_mem=26'd0;  
    busB_mem=32'd0;    
    rw_mem=5'd0;  
    instru_memAddress=0;
end

    always @(posedge clk) begin //遇到控制冒险什么的，在当前周期后半部分解决掉，不能拖到下个周期
        if(~regReset) begin
            branch_mem=branch_ex;
            j_mem=j_ex;
            mem2Reg_mem=mem2Reg_ex;
            regWr_mem=regWr_ex;
            memWr_mem=memWr_ex;
            //rtype_mem=rtype_id;
            overflow_mem=overflow_ex;
            zero_mem=zero_ex;
            sml_mem=sml_ex;
            aluResult_mem=aluResult_ex;
            busB_mem=busB_ex;
            rw_mem=rw_ex;
            rt_mem=rt_ex;
            instru_memAddress=instru_exAddress;
            jumpAddress_mem=jumpAddress_ex;
            imm16_mem=imm16_ex;
            lb_mem=lb_ex;
            lbu_mem=lbu_ex;
            sb_mem=sb_ex;
            link_mem=link_ex;
            busA_mem=busA_ex;
        end
    end
    always @(posedge clk) begin
        if(regReset) begin
            branch_mem=0;
            j_mem=0;
            mem2Reg_mem=0;
            regWr_mem=0;
            memWr_mem=0;
            //rtype_mem=rtype_id;
            overflow_mem=0;
            zero_mem=0;
            sml_mem=0;
            busB_mem=0;
            rw_mem=0;
            jumpAddress_mem=0;
            imm16_mem=0;
            rt_mem=0;
        end

    end 

endmodule