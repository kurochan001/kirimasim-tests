/*
:name: test_integer_types_state_and_signing
:description: bit, byte, shortint, int and longint store x and z as 0 while integer, time, logic and reg keep them; byte, shortint, int, integer and longint are signed and time, bit, reg, logic and their packed arrays unsigned unless signed or unsigned is given; reg has its declared width (IEEE 1800-2023 Section 6.11)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.11 6.11.2 6.11.3 6.9
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_integer_types_state_and_signing.expected
*/
// IEEE 1800-2023 §6.11, Table 6-8, 6.11.2: bit, byte, shortint, int and
// longint are 2-state types, so x and z bits assigned to them become 0;
// integer, time, logic and reg are 4-state and keep x and z. §6.11.3: byte,
// shortint, int, integer and longint are signed by default, while time, bit,
// reg and logic, and packed arrays of them, are unsigned; the keywords signed
// and unsigned change that. A reg has the width of its declared range, one bit
// without one (6.9).
// Each variable is given a value with x and z bits and shown in binary or hex.
// Then each is given all ones ('1) and shown in decimal: the signed types give
// -1, the unsigned ones the largest value of their width, and < 0 is 1 only
// for the signed ones. The variables declared with signed or unsigned show
// the reverse.

module test_integer_types_state_and_signing;
  bit v_bit;
  byte v_byte;
  shortint v_short;
  int v_int;
  longint v_long;
  integer v_integer;
  time v_time;
  logic [7:0] v_logic;
  reg [7:0] v_reg;
  bit [1:0][3:0] v_packed;
  reg r1;
  reg [0:9] r10;
  byte unsigned u_byte = '1;
  int unsigned u_int = '1;
  reg signed [7:0] s_reg = '1;
  logic signed [3:0] s_logic = '1;
  bit signed [3:0] s_bit = '1;
  time signed s_time = '1;

  initial begin
    v_bit = 1'bx;
    v_byte = 8'bx1z0_1x0z;
    v_short = 16'bx1z0_1x0z_1100_0011;
    v_int = 32'hxxxx_1234;
    v_long = 64'hzzzz_0000_xxxx_abcd;
    v_integer = 32'hxxxx_zz34;
    v_time = 64'hzzzz_0000_xxxx_abcd;
    v_logic = 8'bx1z0_1x0z;
    v_reg = 8'bx1z0_1x0z;
    $display("2-state: bit=%b byte=%b shortint=%b int=%h longint=%h", v_bit, v_byte, v_short,
             v_int, v_long);
    $display("4-state: integer=%h time=%h logic=%b reg=%b", v_integer, v_time, v_logic, v_reg);
    v_bit = '1;
    v_byte = '1;
    v_short = '1;
    v_int = '1;
    v_long = '1;
    v_integer = '1;
    v_time = '1;
    v_logic = '1;
    v_reg = '1;
    v_packed = '1;
    $display("signed: byte=%0d shortint=%0d int=%0d integer=%0d longint=%0d", v_byte, v_short,
             v_int, v_integer, v_long);
    $display("unsigned: time=%0d bit=%0d logic=%0d reg=%0d packed=%0d", v_time, v_bit, v_logic,
             v_reg, v_packed);
    $display("below 0: byte=%0d integer=%0d time=%0d reg=%0d packed=%0d", v_byte < 0,
             v_integer < 0, v_time < 0, v_reg < 0, v_packed < 0);
    $display("explicit unsigned: byte=%0d int=%0d", u_byte, u_int);
    $display("explicit signed: reg=%0d logic=%0d bit=%0d time=%0d", s_reg, s_logic, s_bit,
             s_time);
    $display("reg widths: %0d %0d %0d", $bits(r1), $bits(v_reg), $bits(r10));
  end
endmodule
