/*
:name: test_illegal_process_kill_result_used_as_value
:description: The process method kill() is a void function, so assigning the result of a call of it to a variable is an error (IEEE 1800-2023 Section 9.7)
:tags: ch9
:type: elaboration
:lrm: 1800-2023 9.7
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the call p.kill() of the void function kill is used as the source of an assignment to r
:expected_stderr_regex: test_illegal_process_kill_result_used_as_value\.sv:39:
*/
// IEEE 1800-2023 §9.7: the prototype of the class process declares kill()
// as a function void with no arguments. §13.4.1: a call of a function of
// type void is a statement and cannot be used as an expression. The
// initial procedure first assigns p.status(), which returns a state value,
// to the int variable r, which is legal, and then assigns p.kill() to r,
// and that line is the error. With the call p.kill(); as a statement on
// that line the design is legal and prints r=2, since at time 1 the
// process p waits in its delay (WAITING).
// The 5.054 release of Verilator reports on the line of the error that a
// void function cannot be called there. Icarus Verilog 13.0 does not
// compile the class process.

module test_illegal_process_kill_result_used_as_value;
  process p;
  int r;

  initial begin
    fork
      begin
        p = process::self();
        #10 $display("not reached");
      end
    join_none
    #1;
    r = p.status();
    r = p.kill();   // illegal: kill() is a void function
    $display("r=%0d", r);
  end
endmodule
