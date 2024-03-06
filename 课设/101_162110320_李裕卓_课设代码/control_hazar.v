module Control_hazar320(
    input clk,
    input [3:0] j_mem,
    input  usebranch_mem,
    input[5:0] branch_mem,
    input predict,
    output reg regReset
);

initial begin
    regReset=0;
end


always @(negedge clk) begin
    if(regReset==0&&(j_mem || branch_mem&&((usebranch_mem&&predict==0) || (usebranch_mem==0&&predict)) ) ) begin //j型 或者 预测不跳转但是跳转了 或者 预测跳转但是没有跳转
        regReset=1;
        $display("--------handle contrl hazar--------");
    end
    else begin
        regReset=0;
    end
end

endmodule