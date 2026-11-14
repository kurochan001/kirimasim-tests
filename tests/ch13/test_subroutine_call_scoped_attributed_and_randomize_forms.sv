/*
:name: test_subroutine_call_scoped_attributed_and_randomize_forms
:description: subroutine calls by package-scoped and hierarchical names, task calls with and without parentheses, a call with an attribute instance, positional actuals followed by named ones, an empty position and an empty named actual for a default, and std::randomize and randomize calls with inline constraints, as an operand and in a void cast statement (IEEE 1800-2023 Section 13.5)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.5 13.5.4
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_subroutine_call_scoped_attributed_and_randomize_forms.expected
*/
// IEEE 1800-2023 §13.5, Syntax 13-3: a subroutine call is a task or
// function call, a system call, a method call or a randomize call with an
// optional std:: before it, and a call statement may also be a void cast of
// a function call, which discards its value. The name of a task or function
// call may have a package scope or be hierarchical, attribute instances may
// follow the name, and the list of actuals has positional expressions, some
// of which may be left empty, followed by named ones, whose expression may
// be left empty as well. Footnote 42: the parentheses may be left out for a
// task. §13.5.4: a named actual with empty parentheses leaves the formal at
// its default, as an empty position does.
//
// tick has no formals and is called without and with parentheses, so the
// count is 2. cf_pkg::triple(4) is 12. u.bump(5) and u.note("hi") call a
// function and a task of the instance u by hierarchical names, and the
// function returns the new count of u, 5. mix(a, b = 10, c = 100) is called
// with an attribute instance after its name, with one positional actual and
// a named one, and with an empty position: 6, 18 and 16. mix(2, .b(), .c(7))
// leaves b at its default 10, so it is 2 + 10 + 7 = 19 (an empty named
// actual taken as 0 would give 9).
// std::randomize(x) with an inline constraint that allows only 42 returns 1
// and sets x; randomize(y), which outside a class is the same function
// (§18.12), is called in a void cast and sets y to 7, the only value its
// constraint allows. The calls by system name, by method name and with named
// actuals in another order are checked by
// test_subroutine_input_expressions_and_call_forms.
// Icarus Verilog 13.0 does not parse the randomize calls.

package cf_pkg;
  function automatic int triple(input int a);
    return 3 * a;
  endfunction
endpackage

module cf_sub;
  int hits;
  function automatic int bump(input int by);
    hits += by;
    return hits;
  endfunction
  task automatic note(input string s);
    $display("note %s", s);
  endtask
endmodule

module test_subroutine_call_scoped_attributed_and_randomize_forms;
  cf_sub u ();
  int count, r, x, y;
  bit ok;

  task automatic tick;
    count++;
  endtask

  function automatic int mix(input int a, input int b = 10, input int c = 100);
    return a + b + c;
  endfunction

  initial begin
    tick;
    tick();
    $display("task calls: %0d", count);
    $display("package scope: %0d", cf_pkg::triple(4));
    r = u.bump(5);
    u.note("hi");
    $display("hierarchical: %0d %0d", r, u.hits);
    $display("attribute: %0d", mix (* call_tag *) (1, 2, 3));
    $display("positional then named: %0d", mix(1, .c(7)));
    $display("empty position: %0d", mix(1, , 5));
    $display("empty named actual: %0d", mix(2, .b(), .c(7)));
    ok = std::randomize(x) with { x == 42; };
    $display("std::randomize: %0d %0d", ok, x);
    void'(randomize(y) with { y inside {[7:7]}; });
    $display("randomize in void cast: %0d", y);
  end
endmodule
