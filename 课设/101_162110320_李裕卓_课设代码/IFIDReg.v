// IF—ID段寄存器
module IFIDReg_320
(
    input                   clk,              
    input[1:0]                   bubble,             
    input[31:0]           instru_if, 
    input[31:0] instru_ifAddress,
    input regReset,          
    output reg[31:0]          instru_id,
    output reg[31:0] instru_idAddress
    );

    always @(negedge clk) begin
        if(bubble==2'b00) begin
            instru_id=instru_if;
            instru_idAddress=instru_ifAddress;
        end
    end
    always @(posedge regReset) begin //上升沿时说明要重整id
        if(bubble==2'b00) begin
            instru_id=instru_if;
            instru_idAddress=instru_ifAddress;
        end
    end

    initial begin
        instru_idAddress=0;
        instru_id=0;
    end

endmodule
