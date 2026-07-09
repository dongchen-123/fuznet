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
  initial q = (power_up == "high") ? 1'b1 : 1'b0;
  always @(posedge clk or negedge clrn or negedge prn or posedge aload)
    if      (!clrn)  q <= 1'b0;          // async clear  (active low)
    else if (!prn)   q <= 1'b1;          // async preset (active low)
    else if (aload)  q <= asdata;        // async load
    else if (ena) begin
      if      (sclr)  q <= 1'b0;         // sync clear
      else if (sload) q <= asdata;       // sync load
      else            q <= d;
    end
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

// global clock control buffer (inserted by the fitter on the clock network)
module fiftyfivenm_clkctrl (inclk, clkselect, ena, devclrn, devpor, outclk);
  input  [3:0] inclk;
  input  [1:0] clkselect;
  input        ena, devclrn, devpor;
  output       outclk;
  parameter clock_type        = "auto";
  parameter ena_register_mode = "falling edge";
  parameter lpm_type          = "fiftyfivenm_clkctrl";
  assign outclk = inclk[clkselect];   // functional model: pass the selected clock through
endmodule
