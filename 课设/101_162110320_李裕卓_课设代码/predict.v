module predict_320(
    input clk,
    input [5:0] branch_mem,
    input usebranch_mem,
    input predict,
    output reg predict_new
);

initial begin
    predict_new=0;
end

always@(negedge clk) begin
    if(usebranch_mem) predict_new=1;
    else if(branch_mem&&usebranch_mem==0) predict_new=0;
end

endmodule