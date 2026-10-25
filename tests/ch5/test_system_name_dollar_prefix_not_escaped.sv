/*
:name: test_system_name_dollar_prefix_not_escaped
:description: A name that starts with a dollar sign is a system task or function, while an escaped identifier that holds the dollar sign is an ordinary user name, and standard system tasks take no time and can be called where a void function can (IEEE 1800-2023 Section 5.6.3)
:tags: ch5
:type: simulation
:lrm: 1800-2023 5.6.3 5.6.1
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_system_name_dollar_prefix_not_escaped.expected
*/
// IEEE 1800-2023 §5.6.3: a name that follows a $ is a system task or system
// function, and a system task or function identifier is not escaped. An
// escaped identifier can hold any printable character (§5.6.1), so \$clog2
// and \$display are user names, a function and a variable, that do not
// change what $clog2 and $display mean. The standard system tasks take no
// simulation time and can be used where void functions can.
// The test calls the user function \$clog2 and the system function $clog2
// with 8 (108 and 3), and prints the user variable \$display with the system
// task $display. The function show_twice calls $display and $write, which a
// function can do as with void functions; its caller compares $realtime
// before and after the call at time 5.
// Icarus Verilog 13.0 calls the system function $clog2 for \$clog2 (8) and
// prints user=3, although an escaped name is not a system function name.

`timescale 1ns / 1ns

module test_system_name_dollar_prefix_not_escaped;
  int \$display = 9;
  realtime t_before, t_after;

  function automatic int \$clog2 (int x);
    return 100 + x;
  endfunction

  function automatic int show_twice(int x);
    $display("show_twice(%0d)", x);
    $write("write in a function\n");
    return 2 * x;
  endfunction

  initial begin
    $display("user=%0d system=%0d variable=%0d", \$clog2 (8), $clog2(8), \$display );
    #5;
    t_before = $realtime;
    $display("result=%0d", show_twice(21));
    t_after = $realtime;
    $display("time before=%0.1f after=%0.1f", t_before, t_after);
  end
endmodule
