/*
:name: test_stacktrace_function_string_value
:description: $stacktrace called as a function is an expression of type string that can initialize a variable, be an operand of a string concatenation and be discarded with a void cast, and it prints nothing (IEEE 1800-2023 Sections 20.17.2, 20.6.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.17.2 20.6.1 13.4.1 13.5 11.4.12 6.16
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stacktrace_function_string_value.expected
*/
// IEEE 1800-2023 §20.17.2: $stacktrace can be called as a task, which
// displays the call stack, or as a function, which returns the call stack as
// a string instead; what the stack looks like is up to the tool, so the test
// prints only facts that hold for any content, and it never calls the task
// form, whose output could not be compared.
// - $typename gives the self-determined type of its argument without
//   evaluating it (§20.6.1), so for the function form it is "string".
// - The value can initialize a string variable declared in an automatic
//   task, and as an operand of a concatenation with string literals it gives
//   a string (§11.4.12, §6.16), here enclosed in < and >, so the first and
//   last characters are < and >.
// - A void cast holds a function call whose result is discarded (§13.4.1,
//   §13.5: void'(function_subroutine_call) as a statement), so
//   void'($stacktrace) is the function form. Neither that call nor the other
//   function calls print anything, since only the task form displays the
//   stack. So the only lines are the three below.
// - The result is not empty: it holds the stack from the call up to the
//   initial process, at least one level (the same assumption as
//   test_stacktrace_function).
// The 5.052 release of Verilator prints the expected output. Icarus Verilog
// 13.0 stops on an internal assertion when it compiles the calls.

module test_stacktrace_function_string_value;
  string wrapped;

  task automatic probe();
    string here = $stacktrace;
    wrapped = {"<", $stacktrace, ">"};
    void'($stacktrace);
    $display("nonempty: %0d", here.len() > 0);
  endtask

  initial begin
    $display("type: %s", $typename($stacktrace));
    probe();
    $display("ends: %s %s", wrapped.substr(0, 0), wrapped.substr(wrapped.len() - 1,
                                                                   wrapped.len() - 1));
  end
endmodule
