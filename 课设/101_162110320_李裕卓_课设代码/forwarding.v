//数据转发控制单元
module Forwarding_Unit_302(
    input[4:0]     rw_mem,       
    input[4:0]     rw_wr,      
    input[4:0]     rs_ex,              
    input[4:0]     rt_ex,

    input   aluSrc_ex,
    input   regWr_mem,           
    input   regWr_wr,          
    input   mem2Reg_wr,    
    input[1:0] bubble,      

    output reg[1:0]   aluAchoose,              
    output reg[1:0]   aluBchoose
);

    always @(*) begin
    //转发给ALU A端
        // 相邻依赖
        if(rw_mem == rs_ex && regWr_mem && rw_mem != 5'd0 ) begin
            aluAchoose = 2'b01;
        end
        //隔一条指令
        else if(rw_wr == rs_ex && regWr_wr && rw_wr != 5'd0 ) begin
            aluAchoose = 2'b10;            
        end
        // 无需转发
        else begin
            aluAchoose = 2'b00;
        end

    //aluA lw之后两条使用了lw的寄存器
        if ((rw_wr == rs_ex && regWr_wr && rw_wr != 5'd0 )&&mem2Reg_wr) begin
            aluAchoose = 2'b11;            
        end

    //ALU B端
        // 相邻指令
        if (aluSrc_ex==0) begin
            if(rw_mem == rt_ex && regWr_mem && rw_mem != 5'd0 ) begin
                aluBchoose = 2'b01;
                //$display("regWrMem:%d",regWr_mem);
            end
            // 隔一条指令
            else if(rw_wr == rt_ex && regWr_wr && rw_wr != 5'd0 ) begin
                aluBchoose= 2'b10;
            end
            //无需转发
            else begin
                aluBchoose = 2'b00;
            end
        end
        else begin
            aluBchoose=2'b00;
        end
    //ALUB load-use冒险，只要有阻塞并且符合相邻冒险，就说明是loaduse冒险
        if(bubble&&(rw_mem == rt_ex && regWr_mem && rw_mem != 5'd0 )) begin
                aluBchoose = 2'b11;
        end
    end
endmodule