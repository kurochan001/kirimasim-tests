/*
:name: test_udp_initial_value_default_x
:description: A sequential UDP without an initial statement starts with x on its output, and its first level-sensitive entry gives it a known value (IEEE 1800-2023 Section 29.7)
:tags: ch29
:type: simulation
:lrm: 1800-2023 29.7 29.5
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_udp_initial_value_default_x.expected
*/
// IEEE 1800-2023 §29.7: the initial statement of a sequential UDP gives the
// output its value at the start of the simulation; without one the output is
// x. Here the latch holds that x while en is 0, and the entry 1 0 : ? : 0
// gives it 0 when the latch is enabled, and 1 1 : ? : 1 gives it 1.

primitive udp_latch_x (q, en, d);
  output q;
  reg q;
  input en, d;
  table
  // en d : q : q+
    1 0 : ? : 0;
    1 1 : ? : 1;
    0 ? : ? : -;
  endtable
endprimitive

module test_udp_initial_value_default_x;
  reg en, d;
  wire q;

  udp_latch_x u (q, en, d);

  initial begin
    en = 0;
    d = 0;
    #1 $display("en=%b d=%b: q=%b", en, d, q);
    en = 1;
    #1 $display("en=%b d=%b: q=%b", en, d, q);
    d = 1;
    #1 $display("en=%b d=%b: q=%b", en, d, q);
    en = 0;
    d = 0;
    #1 $display("en=%b d=%b: q=%b", en, d, q);
  end
endmodule
