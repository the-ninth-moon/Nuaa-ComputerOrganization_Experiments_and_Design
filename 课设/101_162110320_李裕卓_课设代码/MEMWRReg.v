module MEMWRReg_320(
    input clk,               
    input regReset,//是否出现跳转，出现了就全清零
    //控制信号输入      
    input mem2Reg_mem,             
    input regWr_mem,  
    input link_mem,
    input overflow_mem,
    //input           rtype_mem,                                          
    
    //数据输入     
    
	input[31:0] aluResult_mem,
	input[31:0] data_in,
    input[4:0]  rw_mem,
    input[31:0] instru_memAddress,

    //控制信号输出    
    output reg mem2Reg_wr,             
    output reg regWr_wr,      
    output reg link_wr,
    //output reg      rtype_wr                
        
    
    //数据输出     
    output reg overflow_wr,
	output reg[31:0] aluResult_wr,
	output reg[31:0] data_out, 
    output reg[4:0]  rw_wr,
    output reg[31:0] instru_wrAddress
);
initial begin
    mem2Reg_wr=0;  
    regWr_wr=0;  
    overflow_wr=0;  
    aluResult_wr=0;  
    data_out=0;  
    instru_wrAddress=0;
    rw_wr=0;  
end

    always @(negedge clk) begin
        if(~regReset) begin
            overflow_wr=overflow_mem;
            mem2Reg_wr=mem2Reg_mem;
            //rtype_wr=rtype_mem;
            link_wr=link_mem;
            regWr_wr=regWr_mem;
            aluResult_wr=aluResult_mem;
            data_out=data_in;
            rw_wr=rw_mem;
            instru_wrAddress=instru_memAddress;
        end
        else begin
            regWr_wr=0;
        end
    end

endmodule