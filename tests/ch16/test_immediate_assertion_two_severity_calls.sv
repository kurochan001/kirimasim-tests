/*
:name: test_immediate_assertion_two_severity_calls
:description: when the fail or the pass statement of an immediate assertion calls two severity tasks, both are executed and each message includes its user-defined text (IEEE 1800-2023 Section 16.3)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.3 20.10
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_immediate_assertion_two_severity_calls.expected
:expected_stderr_regex: (?s)(?=.*a_fail report 1 of 2, x=0)(?=.*a_fail report 2 of 2, x=0)(?=.*a_pass report 1 of 2, x=0)(?=.*a_pass report 2 of 2, x=0)
*/
// IEEE 1800-2023 §16.3: if an action block holds more than one severity
// system task, each one is executed as written. §20.10: the message that a
// severity task prints includes its user-defined text. The fail statement of
// a_fail calls $warning and then $info, the pass statement of a_pass calls
// $info twice; all four messages have to appear among the messages of the
// run, in any order, as their place (standard output or standard error) is
// the tool's choice. The display lines after each assertion show that the
// procedure goes on after the actions.

module test_immediate_assertion_two_severity_calls;
  int x = 0;

  initial begin
    a_fail: assert (x == 1) else begin
      $warning("a_fail report 1 of 2, x=%0d", x);
      $info("a_fail report 2 of 2, x=%0d", x);
    end
    $display("after a_fail");
    a_pass: assert (x == 0) begin
      $info("a_pass report 1 of 2, x=%0d", x);
      $info("a_pass report 2 of 2, x=%0d", x);
    end
    $display("after a_pass");
  end
endmodule
