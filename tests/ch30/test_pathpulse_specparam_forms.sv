/*
:name: test_pathpulse_specparam_forms
:description: PATHPULSE$ specparams without terminals and with an input and output terminal, with a reject limit alone and with a reject and an error limit given as min:typ:max expressions, filter the pulses of two module paths (IEEE 1800-2023 Sections 30.7.1, A.2.4)
:tags: ch30
:type: simulation
:lrm: 1800-2023 30.7.1 30.7 30.7.4.1 A.2.4 A.2.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_pathpulse_specparam_forms.expected
*/
// IEEE 1800-2023 A.2.4, §30.7.1: a pulse control specparam is PATHPULSE$,
// optionally followed by an input terminal and an output terminal each after
// a $, assigned a parenthesized reject limit and an optional error limit,
// both constant min:typ:max expressions; one value sets both limits. Without
// terminals it applies to every path of the module, and a path-specific one
// takes precedence. §30.7: a pulse narrower than the reject limit is rejected,
// one at least as wide as the reject limit and narrower than the error limit
// becomes x, and a wider one passes. §30.7.4.1: by default the x starts and
// ends at the times the edges of the pulse were scheduled.
// The two paths of ppf_cell have the delay 6. The list of one specparam
// declaration (A.2.3) holds
// - PATHPULSE$ = (3:3:3): for b => z both limits are 3;
// - PATHPULSE$a$y = (2, 4:4:4): for a => y the reject limit is 2 and the error
//   limit 4.
// (Every min:typ:max triplet has three equal values, so the result does not
// depend on which one a tool selects.) Both inputs carry pulses of width 1 to
// 5, 20 time units apart; the changes of the outputs from time 20 on are
// printed at the end:
//   y: width 1 rejected, 2 and 3 become x, 4 and 5 pass;
//   z: widths 1 and 2 rejected, 3 to 5 pass.
// Icarus Verilog 13.0 stops with a syntax error at the min:typ:max limits,
// and with plain numbers it ignores PATHPULSE$ and rejects every pulse
// narrower than the delay; the other release does not model specify blocks.

`timescale 1ns/1ns

module ppf_cell (input a, b, output y, z);
  buf (y, a);
  buf (z, b);

  specify
    (a => y) = 6;
    (b => z) = 6;
    specparam PATHPULSE$ = (3:3:3), PATHPULSE$a$y = (2, 4:4:4);
  endspecify
endmodule

module test_pathpulse_specparam_forms;
  reg p = 0;
  wire y, z;
  string ly = "", lz = "";

  ppf_cell u (p, p, y, z);

  always @(y) if ($time >= 20) ly = {ly, $sformatf(" %0d:%b", $time, y)};
  always @(z) if ($time >= 20) lz = {lz, $sformatf(" %0d:%b", $time, z)};

  initial begin
    #20 p = 1;
    #1 p = 0;     // 20 to 21: width 1
    #19 p = 1;
    #2 p = 0;     // 40 to 42: width 2
    #18 p = 1;
    #3 p = 0;     // 60 to 63: width 3
    #17 p = 1;
    #4 p = 0;     // 80 to 84: width 4
    #16 p = 1;
    #5 p = 0;     // 100 to 105: width 5
    #25 $display("y:%s", ly);
    $display("z:%s", lz);
  end
endmodule
