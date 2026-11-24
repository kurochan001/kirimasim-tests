/*
:name: test_vpi_udp_no_delay_put_is_visible_in_next_state_transition
:description: An immediate VPI write to a delayed sequential UDP supplies the internal state for its next clock edge
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 37.35 29.6
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_vpi_udp_no_delay_put_is_visible_in_next_state_transition.expected
:vpi_c: @test_vpi_udp_no_delay_put_is_visible_in_next_state_transition.c
*/
`timescale 1ns/1ns

primitive vpi_udp_toggle(q, clock, reset);
  output q;
  reg q;
  input clock, reset;
  table
    ? 1 : ? : 0;
    r 0 : 0 : 1;
    r 0 : 1 : 0;
    f 0 : ? : -;
    ? (10) : ? : -;
  endtable
endprimitive

module test_vpi_udp_no_delay_put_is_visible_in_next_state_transition;
  logic clock = 0, reset = 1;
  wire modified, untouched;
  string changed_log = "", control_log = "";

  vpi_udp_toggle #6 edited(modified, clock, reset);
  vpi_udp_toggle #6 control(untouched, clock, reset);

  always @(modified) if ($time >= 10)
    changed_log = {changed_log, $sformatf(" %0d:%b", $time, modified)};
  always @(untouched) if ($time >= 10)
    control_log = {control_log, $sformatf(" %0d:%b", $time, untouched)};

  initial begin
    #7 reset = 0;
    #2 $display("before=%b%b", modified, untouched);
    #1 $vt_write_udp_state;
    #10 clock = 1;
    #10;
    $display("edited:%s", changed_log);
    $display("control:%s", control_log);
    $vt_require_no_delay_udp;
  end
endmodule
