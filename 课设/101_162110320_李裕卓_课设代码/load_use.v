module load_use320(
    input clk,
    input lw_ex,
    input lb_ex,
    input lbu_ex,
    input[4:0] rs_id,
    input[4:0] rt_id,
    input [4:0] rt_ex,
    input [5:0] usebranch_mem,
    input [3:0] j_mem,
    input[1:0] bubble,
    output reg[1:0] bubble_new
);
initial begin
    bubble_new=0;
end
always@(negedge clk) begin
    if(bubble>0) bubble_new=bubble-1;//bubble大于1就减少
    else if(lw_ex && (rt_ex==rs_id || rt_ex == rt_id)) begin //发生了loaduse冲突
        if (~(j_mem || usebranch_mem)) begin
            bubble_new=1;
        end
    end
end


endmodule
