/*
:name: test_weak_reference_clear_void_no_arguments
:description: weak_reference clear() is a void function without arguments: it is called with an empty argument list as a statement, also inside a function, with no warning, and it makes get() of that reference alone return null (IEEE 1800-2023 Section 8.30.4)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.30.4
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_exit: 0
:expected_stdout: @test_weak_reference_clear_void_no_arguments.expected
:expected_stderr_regex: \A(?![\s\S]*(?i:warn(?:ing)?))[\s\S]*\Z
*/
// IEEE 1800-2023 §8.30.4: clear() has the prototype of a void function with
// no arguments, and clearing a weak reference makes its get() return null.
//
// The test calls clear() with an empty argument list as a statement, in an
// initial procedure and inside a void function that gets the reference as its
// argument. A call that gives no argument does not compile when the method
// needs one. A function shall not enable a task (13.4), so the call inside
// the function needs clear() to be a function. A call of a function that
// returns a value, used as a statement, is legal but shall issue a warning
// (13.4.1), and the regular expression on the messages matches only when they
// do not contain the word warning, so a clear() that returns a value fails
// the test. That warning usually comes when the design is compiled: the
// kirimasim runner checks every message of kirimasim, which compiles and runs
// the design in one step, while the runners of tools with a compile step of
// their own check the messages of the run. Two weak references refer to one
// object, which obj keeps strongly reachable (8.29), so only clear() changes
// what get() returns: clearing one reference leaves the other, and clearing
// does not change the object.

module test_weak_reference_clear_void_no_arguments;
  class token;
    int n;
  endclass

  typedef weak_reference #(token) token_ref;

  token obj;
  token_ref first, second;

  function automatic void drop(token_ref r);
    r.clear();
  endfunction

  initial begin
    obj = new();
    obj.n = 3;
    first = new(obj);
    second = new(obj);
    $display("before: first is obj %0d, second is obj %0d", first.get() == obj,
             second.get() == obj);
    first.clear();
    $display("first.clear(): first is null %0d, second is obj %0d", first.get() == null,
             second.get() == obj);
    drop(second);
    $display("clear() inside a function: second is null %0d, obj.n %0d", second.get() == null,
             obj.n);
    first.clear();
    $display("clear() again: first is null %0d", first.get() == null);
  end
endmodule
