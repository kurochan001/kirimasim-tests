/*
:name: test_illegal_final_procedure_event_control
:description: A final procedure can only contain the statements allowed in a function, so it cannot contain an event control (IEEE 1800-2023 Section 9.2.3)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.2.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the second final procedure waits with the event control @(done)
:expected_stderr_regex: test_illegal_final_procedure_event_control\.sv:37:
*/
// IEEE 1800-2023 §9.2.3: the only statements allowed in a final procedure
// are those permitted in a function declaration. §13.4 a): a function shall
// not contain time-controlling statements, among them any statement with @.
// The first final procedure prints a value, which a function may do; the
// second one waits for the event done before printing, and that line is the
// error. Without the event control the design is legal and prints count=2
// and late, in either order (the order of final procedures is not fixed).
// Icarus Verilog 13.0 reports on the line of the error that a final
// procedure cannot have an event statement. The 5.054 release of Verilator
// does not report the event control and fails to compile the C++ code it
// generates.

module test_illegal_final_procedure_event_control;
  event done;
  int count;

  initial begin
    count = 2;
    #5 $finish;
  end

  final $display("count=%0d", count);

  final @(done) $display("late");   // illegal: an event control in a final procedure
endmodule
