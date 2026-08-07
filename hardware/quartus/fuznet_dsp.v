module dsp_w9 (
    input clk,
    input [8:0] a,
    input [8:0] b,
    output reg [17:0] out
);
always@(posedge clk) begin
    out <= a * b;
end
endmodule