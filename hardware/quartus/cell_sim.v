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

//--------------------------------------------------------------------------
// Module Name     : fiftyfivenm_ram_block
// Description     : Main RAM module
//--------------------------------------------------------------------------

module fiftyfivenm_ram_block
    (
     portadatain,
     portaaddr,
     portawe,
     portare,
     portbdatain,
     portbaddr,
     portbwe,
     portbre,
     clk0, clk1,
     ena0, ena1,
     ena2, ena3,
     clr0, clr1,
     portabyteenamasks,
     portbbyteenamasks,
     portaaddrstall,
     portbaddrstall,
     devclrn,
     devpor,
     portadataout,
     portbdataout
     );
// -------- GLOBAL PARAMETERS ---------
parameter operation_mode = "single_port";
parameter mixed_port_feed_through_mode = "dont_care";
parameter ram_block_type = "auto";
parameter logical_ram_name = "ram_name";

parameter init_file = "init_file.hex";
parameter init_file_layout = "none";

parameter data_interleave_width_in_bits = 1;
parameter data_interleave_offset_in_bits = 1;
parameter port_a_logical_ram_depth = 0;
parameter port_a_logical_ram_width = 0;
parameter port_a_first_address = 0;
parameter port_a_last_address = 0;
parameter port_a_first_bit_number = 0;

parameter port_a_data_out_clear = "none";

parameter port_a_data_out_clock = "none";

parameter port_a_data_width = 1;
parameter port_a_address_width = 1;
parameter port_a_byte_enable_mask_width = 1;

parameter port_b_logical_ram_depth = 0;
parameter port_b_logical_ram_width = 0;
parameter port_b_first_address = 0;
parameter port_b_last_address = 0;
parameter port_b_first_bit_number = 0;

parameter port_b_address_clear = "none";
parameter port_b_data_out_clear = "none";

parameter port_b_data_in_clock = "clock1";
parameter port_b_address_clock = "clock1";
parameter port_b_write_enable_clock = "clock1";
parameter port_b_read_enable_clock  = "clock1";
parameter port_b_byte_enable_clock = "clock1";
parameter port_b_data_out_clock = "none";

parameter port_b_data_width = 1;
parameter port_b_address_width = 1;
parameter port_b_byte_enable_mask_width = 1;

parameter port_a_read_during_write_mode = "new_data_no_nbe_read";
parameter port_b_read_during_write_mode = "new_data_no_nbe_read";
parameter power_up_uninitialized = "false";
parameter lpm_type = "fiftyfivenm_ram_block";
parameter lpm_hint = "true";
parameter connectivity_checking = "off";

 parameter mem_init0 = 2048'b0;
 parameter mem_init1 = 2048'b0;
 parameter mem_init2 = 2048'b0;
 parameter mem_init3 = 2048'b0;
 parameter mem_init4 = 2048'b0;

parameter port_a_byte_size = 0;
parameter port_b_byte_size = 0;
parameter safe_write = "err_on_2clk";
parameter init_file_restructured = "unused";

parameter clk0_input_clock_enable  = "none"; // ena0,ena2,none
parameter clk0_core_clock_enable   = "none"; // ena0,ena2,none
parameter clk0_output_clock_enable = "none"; // ena0,none
parameter clk1_input_clock_enable  = "none"; // ena1,ena3,none
parameter clk1_core_clock_enable   = "none"; // ena1,ena3,none
parameter clk1_output_clock_enable = "none"; // ena1,none

// simulation-only params
parameter port_a_address_clear      = "none";
parameter port_a_data_in_clock      = "clock0";
parameter port_a_address_clock      = "clock0";
parameter port_a_write_enable_clock = "clock0";
parameter port_a_byte_enable_clock  = "clock0";
parameter port_a_read_enable_clock  = "clock0";


// -------- PORT DECLARATIONS ---------
input portawe;
input portare;
input [port_a_data_width - 1:0] portadatain;
input [port_a_address_width - 1:0] portaaddr;
input [port_a_byte_enable_mask_width - 1:0] portabyteenamasks;

input portbwe, portbre;
input [port_b_data_width - 1:0] portbdatain;
input [port_b_address_width - 1:0] portbaddr;
input [port_b_byte_enable_mask_width - 1:0] portbbyteenamasks;

input clr0,clr1;
input clk0,clk1;
input ena0,ena1;
input ena2,ena3;

input devclrn,devpor;
input portaaddrstall;
input portbaddrstall;
output [port_a_data_width - 1:0] portadataout;
output [port_b_data_width - 1:0] portbdataout;
// ---- behavioral single-port model (clean-room; atoms used only as spec) ----
  localparam DEPTH = (1 << port_a_address_width);
  reg [port_a_data_width-1:0]    mem [0:DEPTH-1];
  reg [port_a_address_width-1:0] addr_a_reg;
  integer i;

  initial begin
    if (power_up_uninitialized == "false")
      for (i = 0; i < DEPTH; i = i + 1) mem[i] = {port_a_data_width{1'b0}};
    addr_a_reg = {port_a_address_width{1'b0}};
  end

  always @(posedge clk0)
    if (ena0) begin
      if (portawe) mem[portaaddr] <= portadatain;   // synchronous write, ena-gated
      addr_a_reg <= portaaddr;             // address (M9K)
    end

  assign portadataout = mem[addr_a_reg];             // unregistered read (data_out_clock="none")
  assign portbdataout = {port_b_data_width{1'b0}};

endmodule


module fiftyfivenm_mac_mult
   (
    dataa,
    datab,
    signa,
    signb,
    clk,
    aclr,
    ena,
    dataout,
    devclrn,
    devpor
    );

    parameter dataa_width = 1;
    parameter datab_width = 1;
    parameter lpm_hint = "true";
    parameter lpm_type = "fiftyfivenm_mac_mult";
    parameter dataa_clock = "none";
    parameter datab_clock = "none";
    parameter signa_clock = "none";
    parameter signb_clock = "none";


// SIMULATION_ONLY_PARAMETERS_BEGIN

    parameter dataout_width  = dataa_width + datab_width;

// SIMULATION_ONLY_PARAMETERS_END

    input [dataa_width-1:0] dataa;
    input [datab_width-1:0] datab;
    input signa;
    input signb;
    input clk;
    input aclr;
    input ena;
    input devclrn;
    input devpor;

    output [dataout_width-1:0] dataout;

  wire signed [dataa_width:0] ea_c = signa ? {dataa[dataa_width-1], dataa} : {1'b0, dataa};
  wire signed [datab_width:0] eb_c = signb ? {datab[datab_width-1], datab} : {1'b0, datab};

  // Optional per-operand input registers. The fitter enables them by setting
  // dataa_clock/datab_clock != "none" (clocked on clk, ena-gated); "none"
  // keeps the operand combinational.
  reg signed [dataa_width:0] ea_r;
  reg signed [datab_width:0] eb_r;
  initial begin ea_r = 0; eb_r = 0; end
  always @(posedge clk)
    if (ena) begin ea_r <= ea_c; eb_r <= eb_c; end

  wire signed [dataa_width:0] ea = (dataa_clock == "none") ? ea_c : ea_r;
  wire signed [datab_width:0] eb = (datab_clock == "none") ? eb_c : eb_r;
  assign dataout = ea * eb;

endmodule

module fiftyfivenm_mac_out (
    dataa, clk, aclr, ena, dataout, devclrn, devpor);

    parameter dataa_width  = 1;
    parameter output_clock = "none";
    parameter lpm_hint     = "true";
    parameter lpm_type     = "fiftyfivenm_mac_out";

    input  [dataa_width-1:0] dataa;
    input  clk, aclr, ena, devclrn, devpor;
    output [dataa_width-1:0] dataout;

    // The fitter may absorb the DSP output register into this block by setting
    // output_clock != "none" (e.g. "0"), the result is then registered on clk
    // (ena-gated, power-up 0). output_clock == "none" stays combinational.
    reg [dataa_width-1:0] dataout_r;
    initial dataout_r = {dataa_width{1'b0}};
    always @(posedge clk)
      if (ena) dataout_r <= dataa;
    assign dataout = (output_clock == "none") ? dataa : dataout_r;
endmodule
