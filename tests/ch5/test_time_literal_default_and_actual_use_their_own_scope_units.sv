/*
:name: test_time_literal_default_and_actual_use_their_own_scope_units
:description: A time literal in a default argument and the same literal at two call sites yields three values from their lexical units
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.8 13.5.3 3.14.2.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_time_literal_default_and_actual_use_their_own_scope_units.expected
*/
package declared_delay_default;
  timeunit 10ns;
  timeprecision 1ns;

  function automatic realtime read_argument(input realtime duration = 555ps);
    return duration;
  endfunction
endpackage

module argument_in_one_ns_scope(output var real default_result, explicit_result);
  timeunit 1ns;
  timeprecision 100ps;
  import declared_delay_default::read_argument;

  initial begin
    default_result = read_argument();
    explicit_result = read_argument(555ps);
  end
endmodule

module test_time_literal_default_and_actual_use_their_own_scope_units;
  timeunit 1ps;
  timeprecision 1ps;
  import declared_delay_default::read_argument;

  real child_default, child_explicit;
  argument_in_one_ns_scope child(child_default, child_explicit);

  initial #1 begin
    $display("default top=%0.4f child=%0.4f", read_argument(), child_default);
    $display("explicit top=%0.4f child=%0.4f", read_argument(555ps), child_explicit);
    $display("plain top=%0.4f", read_argument(0.125));
    $finish(0);
  end
endmodule
