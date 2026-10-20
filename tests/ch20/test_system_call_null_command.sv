/*
:name: test_system_call_null_command
:description: $system called without a command calls the C function system() with a null pointer, which returns nonzero when a command processor is available (IEEE 1800-2023 Section 20.17.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.17.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_call_null_command.expected
*/
// IEEE 1800-2023 §20.17.1: when $system has no string argument, the C
// function system() is called with a null pointer. In C that asks whether a
// command processor exists and gives a nonzero value if one does, as on the
// systems the suite runs on; nothing is run.

module test_system_call_null_command;
  int shell;

  initial begin
    shell = $system();
    $display("command processor found: %0d", shell != 0);
  end
endmodule
