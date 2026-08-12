module ram_w9_a4 (
    input clk,
    input we,
    input [3:0] addr,
    input [8:0] din,
    output [8:0] dout
);

reg [8:0] mem [0:15];
reg [3:0] addr_q;
always@(posedge clk) begin
    if (we) mem[addr] <= din;
    addr_q <= addr;
end
assign dout = mem[addr_q];
endmodule