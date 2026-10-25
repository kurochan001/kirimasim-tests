/*
:name: test_function_directions_both_formal_styles
:description: Function formals declared in parentheses or by declarations in the body behave alike, and their input, output, inout and ref directions copy in, copy out at the end, do both, or refer to the actual as for a task (IEEE 1800-2023 Section 13.4)
:tags: ch13
:type: simulation
:lrm: 1800-2023 13.4 13.3 13.5.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_function_directions_both_formal_styles.expected
*/
// IEEE 1800-2023 §13.4: a function declares its formals either in
// parentheses or by direction declarations in its body, and its directions
// are those of a task (13.3): input copies the value in at the beginning,
// output copies it out at the end, inout does both, and ref passes a
// reference (13.5.2).
//
// ansi_f has its formals in parentheses, body_f declares the same ones in
// its body, and the task ansi_t has them too. Each is called with v (= 1)
// for both the input i and the ref r, o for the output and io (= 10) for
// the inout. Inside, writing r = 100 changes v at once, while i keeps the
// copied 1; the new values of out and x are not yet in o and io. After the
// call, o and io have them, and writing i = 7 inside did not reach v.

module test_function_directions_both_formal_styles;
  int v, o, io, unused;

  function automatic int ansi_f(input int i, output int out, inout int x, ref int r);
    r = 100;
    out = 5;
    x = x + 1;
    $display("  inside: i=%0d r=%0d v=%0d o=%0d io=%0d out=%0d x=%0d", i, r, v, o, io, out, x);
    i = 7;
    return 0;
  endfunction

  function automatic int body_f;
    input int i;
    output int out;
    inout int x;
    ref int r;
    r = 100;
    out = 5;
    x = x + 1;
    $display("  inside: i=%0d r=%0d v=%0d o=%0d io=%0d out=%0d x=%0d", i, r, v, o, io, out, x);
    i = 7;
    return 0;
  endfunction

  task automatic ansi_t(input int i, output int out, inout int x, ref int r);
    r = 100;
    out = 5;
    x = x + 1;
    $display("  inside: i=%0d r=%0d v=%0d o=%0d io=%0d out=%0d x=%0d", i, r, v, o, io, out, x);
    i = 7;
  endtask

  task automatic reset();
    v = 1;
    o = -1;
    io = 10;
  endtask

  initial begin
    reset();
    $display("function, formals in parentheses:");
    unused = ansi_f(v, o, io, v);
    $display("  after: v=%0d o=%0d io=%0d", v, o, io);
    reset();
    $display("function, formals declared in the body:");
    unused = body_f(v, o, io, v);
    $display("  after: v=%0d o=%0d io=%0d", v, o, io);
    reset();
    $display("task:");
    ansi_t(v, o, io, v);
    $display("  after: v=%0d o=%0d io=%0d", v, o, io);
  end
endmodule
