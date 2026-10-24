/*
:name: test_illegal_new_process_object
:description: a process object cannot be created with new (IEEE 1800-2023 Section 9.7)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: new is called to create an object of the built-in class process
:expected_stderr_regex: test_illegal_new_process_object\.sv:25:
*/
// IEEE 1800-2023 §9.7: objects of the built-in class process are created when
// processes are spawned, and process::self() returns the handle of the
// current one. Users cannot create process objects: calling new shall not
// create a process and shall instead result in an error.
// Icarus Verilog 13.0 does not support the process class, and Verilator 5.052
// accepts the design.

module test_illegal_new_process_object;
  process p, q;
  initial begin
    p = process::self();
    q = new;   // illegal: a process object cannot be created by the user
    $display("%0d", p != null);
  end
endmodule
