module ram_w1_a4 (
    input clk,
    input we,
    input [3:0] addr, 
    input din,
    output dout
);

reg mem [0:15];
reg[3:0] addr_q;
always@(posedge clk) begin
    if (we) mem[addr] <= din;
    addr_q <= addr;
end
assign dout = mem[addr_q];

endmodule
