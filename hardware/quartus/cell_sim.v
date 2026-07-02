`timescale 1 ps/1 ps

module fiftyfivenm_lcell_comb (dataa, datab, datac, datad, cin, combout, cout);
  input  dataa, datab, datac, datad, cin;
  output combout, cout;
  parameter [15:0] lut_mask       = 16'hFFFF;
  parameter        sum_lutc_input = "datac";
  assign combout = lut_mask[{datad, datac, datab, dataa}];
  assign cout    = 1'b0;
endmodule

module dffeas (d, clk, ena, clrn, prn, aload, asdata, sclr, sload, devclrn, devpor, q);
  input  d, clk, ena, clrn, prn, aload, asdata, sclr, sload, devclrn, devpor;
  output reg q;
  parameter is_wysiwyg = "true";
  parameter power_up   = "low";
  always @(posedge clk or negedge clrn or negedge prn)
    if      (!clrn) q <= 1'b0;
    else if (!prn)  q <= 1'b1;
    else if (ena)   q <= d;
endmodule

module fiftyfivenm_io_ibuf (i, ibar, nsleep, o);
  input  i, ibar, nsleep;  output o;
  parameter bus_hold = "false";
  parameter listen_to_nsleep_signal = "false";
  parameter simulate_z_as = "z";
  assign o = i;
endmodule

module fiftyfivenm_io_obuf (i, oe, seriesterminationcontrol, devoe, o, obar);
  input  i, oe, devoe;  input [15:0] seriesterminationcontrol;  output o, obar;
  parameter bus_hold = "false";
  parameter open_drain_output = "false";
  assign o = i;  assign obar = ~i;
endmodule
