/*
:name: test_stacktrace_function_call_contexts
:description: the function form of $stacktrace returns a string from inside a function, a class method, a process spawned by fork-join_none and a final procedure, and its calls print nothing (IEEE 1800-2023 Section 20.17.2)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.17.2 13.4 8.10 9.3.2 9.2.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_stacktrace_function_call_contexts.expected
*/
// IEEE 1800-2023 §20.17.2: called as a function, $stacktrace returns a
// string with the call stack from the place of the call up to the top-level
// process; the content is up to the tool. A system function call that does
// not consume time may appear in a function (§13.4), so the function form can
// be used in a function, in a static class method (§8.10), in a process that
// fork-join_none spawns (§9.3.2), where the stack ends at that process, and
// in a final procedure (§9.2.3). Each call gives a string; the test prints
// only whether it is not empty (it holds at least the level of the call, the
// same assumption as test_stacktrace_function) and never prints the content.
// None of these calls prints anything itself, since only the task form
// displays the stack. The forked process runs at time 1, after the initial
// process has printed its lines and waits at #2, so the lines come in the
// order below; the final procedure runs when the simulation ends.
// The 5.052 release of Verilator prints the expected output. Icarus Verilog
// 13.0 reports a syntax error on the call of the static class method.

module test_stacktrace_function_call_contexts;
  class tracer;
    static function string trace_here();
      return $stacktrace;
    endfunction
  endclass

  function automatic string from_function(int depth);
    if (depth > 0) return from_function(depth - 1);
    return $stacktrace;
  endfunction

  string forked_trace;

  initial begin
    string s;
    s = from_function(3);
    $display("function: %0d", s.len() > 0);
    s = tracer::trace_here();
    $display("class method: %0d", s.len() > 0);
    fork
      #1 forked_trace = $stacktrace;
    join_none
    #2;
    $display("forked process: %0d", forked_trace.len() > 0);
  end

  final begin
    string f;
    f = $stacktrace;
    $display("final: %0d", f.len() > 0);
  end
endmodule
