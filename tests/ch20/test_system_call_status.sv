/*
:name: test_system_call_status
:description: $system runs a shell command through the C function system() and, called as a function, returns its result as an int, 0 for a command that succeeds (IEEE 1800-2023 Section 20.17.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.17.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_call_status.expected
*/
// IEEE 1800-2023 §20.17.1: $system passes its command to the C function
// system(), and called as a function it returns what system() returns, as an
// int. The commands print nothing. A command that succeeds gives 0 and one
// that exits with 3 gives a nonzero status; how system() encodes the status is
// up to the C library, so the test does not print the number. Called as a
// task, $system also runs the command. test_system_call_null_command calls it
// without an argument.

module test_system_call_status;
  int ok, failed;

  initial begin
    ok = $system("exit 0");
    failed = $system("exit 3");
    $system("exit 0");
    $display("success gives 0: %0d, failure nonzero: %0d", ok == 0, failed != 0);
  end
endmodule
