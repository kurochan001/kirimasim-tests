/*
:name: test_process_state_enum_names_and_order
:description: The enumeration type state of the built-in class process has the names FINISHED, RUNNING, WAITING, SUSPENDED and KILLED in that order, so stepping a process::state variable from first() with next() gives them with the values 0 to 4 (IEEE 1800-2023 Section 9.7)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.7
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_process_state_enum_names_and_order.expected
*/
// IEEE 1800-2023 §9.7: the prototype of the class process declares the
// enumeration type state with the names FINISHED, RUNNING, WAITING,
// SUSPENDED and KILLED, in this order and without explicit values, so they
// have the values 0 to 4 (§6.19). The variable s of type process::state
// starts at s.first() and is stepped with s.next() (§6.19.5); each step
// prints the position, the value of s and its name(). The last line prints
// num(), the number of names, and the values of the names written with the
// class scope, process::KILLED and process::FINISHED. Another order of the
// names would change the names printed on the lines 0 to 4, and another set
// of names would change num() or the names.
// Icarus Verilog 13.0 does not compile the class process.

module test_process_state_enum_names_and_order;
  initial begin
    process::state s;
    s = s.first();
    for (int i = 0; i < 5; i++) begin
      $display("%0d: %0d %s", i, s, s.name());
      s = s.next();
    end
    $display("num=%0d KILLED=%0d FINISHED=%0d", s.num(), process::KILLED, process::FINISHED);
  end
endmodule
