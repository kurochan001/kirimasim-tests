/*
:name: test_mos_cmos_switch_delay_forms
:description: nmos, pmos and cmos switches with no delay, one, two and three delays change their output after the rise, fall, turn-off or x delay, and a change to H or L takes the x delay (IEEE 1800-2023 Sections 28.7 and 28.9)
:tags: ch28
:type: simulation
:lrm: 1800-2023 28.7 28.9 28.16 21.2.1.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_mos_cmos_switch_delay_forms.expected
*/
// IEEE 1800-2023 §28.7 and §28.9: the MOS and CMOS switches take zero, one,
// two or three delays. Without a delay the output changes at once, and one
// delay is used for every change. With two delays d1 is used for a change to
// 1, d2 for a change to 0 and the smaller of the two for a change to x or z;
// with three delays d1, d2 and d3 are used for a change to 1, 0 and z and
// the smallest of the three for a change to x. A change to H or L takes the
// delay of a change to x. Seven nmos, seven pmos and seven cmos switches
// with the delays none, 4, (3,5), (5,3), (2,4,6), (6,2,4) and (4,6,2) share
// one data input and one control c; the pmos switches and the p-channel
// control of each cmos get the inverse of c, so all switches are on, all
// off or all unknown together and drive the same value. The inputs take
// the outputs through the 12 changes between 0, 1, x and z and then into
// and out of L and H. For every switch
// an always procedure records the time of the last change of its output,
// and 9 time units after each input change the delay since that change and
// the output with its strength (%v, 21.2.1.4) are printed. Every step also
// changes the logic value of the outputs (H and L are x), so that the
// always procedures see it.

`timescale 1ns/1ns
module test_mos_cmos_switch_delay_forms;
  logic [2:0] v;  // {data, n-channel control, p-channel control}
  wire n_0, n_4, n_35, n_53, n_246, n_624, n_462;
  wire p_0, p_4, p_35, p_53, p_246, p_624, p_462;
  wire c_0, c_4, c_35, c_53, c_246, c_624, c_462;

  nmos sn_0(n_0, v[2], v[1]);
  nmos #4 sn_4(n_4, v[2], v[1]);
  nmos #(3, 5) sn_35(n_35, v[2], v[1]);
  nmos #(5, 3) sn_53(n_53, v[2], v[1]);
  nmos #(2, 4, 6) sn_246(n_246, v[2], v[1]);
  nmos #(6, 2, 4) sn_624(n_624, v[2], v[1]);
  nmos #(4, 6, 2) sn_462(n_462, v[2], v[1]);
  pmos sp_0(p_0, v[2], v[0]);
  pmos #4 sp_4(p_4, v[2], v[0]);
  pmos #(3, 5) sp_35(p_35, v[2], v[0]);
  pmos #(5, 3) sp_53(p_53, v[2], v[0]);
  pmos #(2, 4, 6) sp_246(p_246, v[2], v[0]);
  pmos #(6, 2, 4) sp_624(p_624, v[2], v[0]);
  pmos #(4, 6, 2) sp_462(p_462, v[2], v[0]);
  cmos sc_0(c_0, v[2], v[1], v[0]);
  cmos #4 sc_4(c_4, v[2], v[1], v[0]);
  cmos #(3, 5) sc_35(c_35, v[2], v[1], v[0]);
  cmos #(5, 3) sc_53(c_53, v[2], v[1], v[0]);
  cmos #(2, 4, 6) sc_246(c_246, v[2], v[1], v[0]);
  cmos #(6, 2, 4) sc_624(c_624, v[2], v[1], v[0]);
  cmos #(4, 6, 2) sc_462(c_462, v[2], v[1], v[0]);

  time tn[7], tp[7], tc[7];
  always @(n_0) tn[0] = $time;
  always @(n_4) tn[1] = $time;
  always @(n_35) tn[2] = $time;
  always @(n_53) tn[3] = $time;
  always @(n_246) tn[4] = $time;
  always @(n_624) tn[5] = $time;
  always @(n_462) tn[6] = $time;
  always @(p_0) tp[0] = $time;
  always @(p_4) tp[1] = $time;
  always @(p_35) tp[2] = $time;
  always @(p_53) tp[3] = $time;
  always @(p_246) tp[4] = $time;
  always @(p_624) tp[5] = $time;
  always @(p_462) tp[6] = $time;
  always @(c_0) tc[0] = $time;
  always @(c_4) tc[1] = $time;
  always @(c_35) tc[2] = $time;
  always @(c_53) tc[3] = $time;
  always @(c_246) tc[4] = $time;
  always @(c_624) tc[5] = $time;
  always @(c_462) tc[6] = $time;

  // Applies the next inputs: data d, control c of the nmos switches and the
  // n-channel of the cmos switches, and ~c for the others.
  task automatic step(string what, logic d, logic c);
    time t;
    v = {d, c, ~c};
    t = $time;
    #9;
    $write("%s nmos: none=+%0d %v one=+%0d %v (3,5)=+%0d %v (5,3)=+%0d %v", what,
           tn[0] - t, n_0, tn[1] - t, n_4, tn[2] - t, n_35, tn[3] - t, n_53);
    $display(" (2,4,6)=+%0d %v (6,2,4)=+%0d %v (4,6,2)=+%0d %v",
             tn[4] - t, n_246, tn[5] - t, n_624, tn[6] - t, n_462);
    $write("%s pmos: none=+%0d %v one=+%0d %v (3,5)=+%0d %v (5,3)=+%0d %v", what,
           tp[0] - t, p_0, tp[1] - t, p_4, tp[2] - t, p_35, tp[3] - t, p_53);
    $display(" (2,4,6)=+%0d %v (6,2,4)=+%0d %v (4,6,2)=+%0d %v",
             tp[4] - t, p_246, tp[5] - t, p_624, tp[6] - t, p_462);
    $write("%s cmos: none=+%0d %v one=+%0d %v (3,5)=+%0d %v (5,3)=+%0d %v", what,
           tc[0] - t, c_0, tc[1] - t, c_4, tc[2] - t, c_35, tc[3] - t, c_53);
    $display(" (2,4,6)=+%0d %v (6,2,4)=+%0d %v (4,6,2)=+%0d %v",
             tc[4] - t, c_246, tc[5] - t, c_624, tc[6] - t, c_462);
    #1;
  endtask

  initial begin
    v = 3'b010;  // output 0
    #10;
    step("0->1", 1'b1, 1'b1);
    step("1->0", 1'b0, 1'b1);
    step("0->x", 1'bx, 1'b1);
    step("x->0", 1'b0, 1'b1);
    step("0->z", 1'b0, 1'b0);
    step("z->1", 1'b1, 1'b1);
    step("1->x", 1'bx, 1'b1);
    step("x->1", 1'b1, 1'b1);
    step("1->z", 1'b1, 1'b0);
    step("z->x", 1'bx, 1'b1);
    step("x->z", 1'bx, 1'b0);
    step("z->0", 1'b0, 1'b1);
    step("0->L", 1'b0, 1'bx);
    step("L->z", 1'b0, 1'b0);
    step("z->H", 1'b1, 1'bx);
    step("H->1", 1'b1, 1'b1);
    step("1->H", 1'b1, 1'bx);
    step("H->z", 1'b1, 1'b0);
    step("z->L", 1'b0, 1'bx);
    step("L->0", 1'b0, 1'b1);
  end
endmodule
