module IDEXReg_320(
    input   clk,                //时钟信号输入
    input   regReset,
    input   bubble,              //阻塞信号输入

    //控制信号输入
    input[5:0]   branch_id,           
    input[3:0]   j_id,    
    input   regDst_id,           
    input   aluSrc_id,    
    input   link_id,
    input lw_id,
    input   lb_id,
    input   lbu_id,
    input   sb_id,
    input   useshamt_id,        
    input[4:0] aluCtr_id,           
    input   mem2Reg_id,             
    input   regWr_id,            
    input   memWr_id,            
    input   extOp_id,            
    input   rtype_id,          
    
    //数据输入     
    input[31:0]   busA_id,            //Reg[Rs]      
    input[31:0]   busB_id,            //Reg[Rt]
    input[4:0] shamt_id,   
    input[15:0]   imm16_id,           //输入imm16
    input[25:0]   jumpAddress_id,
    input[4:0]    rs_id, 
    input[4:0]    rt_id,              
    input[4:0]    rd_id,  
    input[31:0]   instru_idAddress,

    //控制信号输出
    output reg[5:0]  branch_ex,           
    output reg[3:0]  j_ex,    
    output reg  regDst_ex,           
    output reg  aluSrc_ex, 
    output reg  link_ex,
    output reg lw_ex,
    output reg  lb_ex,
    output reg  lbu_ex,
    output reg  sb_ex,
    output reg  useshamt_ex,  

    output reg[4:0]  aluCtr_ex,           
    output reg  mem2Reg_ex,             
    output reg  regWr_ex,            
    output reg  memWr_ex,            
    output reg  extOp_ex,            
    output reg  rtype_ex,           

    //数据输出  
    output reg[31:0]   busA_ex,            //Reg[Rs]      
    output reg[31:0]   busB_ex,            //Reg[Rt]    
    output reg[4:0]    shamt_ex,    
    output reg[15:0]   imm16_ex, 
    output reg[25:0]   jumpAddress_ex,    
    output reg[4:0]    rs_ex,             
    output reg[4:0]    rt_ex,              
    output reg[4:0]    rd_ex,
    output reg[31:0]   instru_exAddress           
);

    initial begin
        branch_ex=0;         
        j_ex=0;
        regDst_ex=0;          
        aluSrc_ex=0;         
        aluCtr_ex=0;           
        mem2Reg_ex=0;             
        regWr_ex=0;            
        memWr_ex=0;            
        extOp_ex=0;            
        rtype_ex=0;           

        //数据输出  
        busA_ex=0;           //Reg[Rs]      
        busB_ex=0;            //Reg[Rt]        
        imm16_ex=0; 
        jumpAddress_ex=0;                 
        rt_ex=0;   
        rd_ex=0;
        instru_exAddress=0;
    end
    always @(negedge clk) begin
        if(bubble==2'b00) begin
            // 控制信号保存
			branch_ex=branch_id;
			j_ex=j_id;
			regDst_ex=regDst_id;
			aluSrc_ex=aluSrc_id;
            link_ex = link_id;
            lw_ex=lw_id;
            lb_ex=lb_id;
            lbu_ex=lbu_id;
            sb_ex=sb_id;
            useshamt_ex=useshamt_id; 
			aluCtr_ex=aluCtr_id;
			mem2Reg_ex=mem2Reg_id;
			regWr_ex=regWr_id;
			memWr_ex=memWr_id;
			extOp_ex=extOp_id;
            lw_ex=lw_id;
			//rtype_ex=rtype_id;
            // 数据信号保存
			busA_ex=busA_id;
			busB_ex=busB_id;
			imm16_ex=imm16_id;
            shamt_ex=shamt_id;
            jumpAddress_ex=jumpAddress_id;
            rs_ex=rs_id;
			rt_ex=rt_id;
			rd_ex=rd_id;
            instru_exAddress=instru_idAddress;
        end
        if((bubble!=2'b00)||regReset) begin
			branch_ex=0;
			j_ex=0;
			regDst_ex=0;
			//aluSrc_ex=0;
			//aluCtr_ex=0;
			//mem2Reg_ex=0;
			regWr_ex=0;
			memWr_ex=0;
			//extOp_ex=0;
            //lw_ex=0;
			//rtype_ex=rtype_id;
            // 数据信号保存
			busA_ex=0;
			busB_ex=0;
			imm16_ex=0;
            rs_ex=0;
			rt_ex=0;
			rd_ex=0;
        end
    end 

endmodule