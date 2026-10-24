/*
:name: test_timeunit_exponent_table
:description: $timeunit gives for each of the 18 possible time units, from 100 s down to 1 fs, the integer of Table 20-2, from 2 down to -15 (IEEE 1800-2023 Section 20.4.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.4.1 3.14.2.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeunit_exponent_table.expected
*/
// IEEE 1800-2023 §20.4.1: $timeunit returns the time unit of a design element
// as an integer from 2 down to -15, the power of ten of the unit in seconds
// that Table 20-2 gives: 2 for 100 s, 1 for 10 s, 0 for 1 s and so on down to
// -15 for 1 fs. Without an argument it gives the unit of the design element
// of the current scope. Each module below declares one of the 18 time units
// with a timeunit declaration (3.14.2.2), all with the precision 1 fs, and
// has a function that returns $timeunit; inside the function the current
// scope belongs to that module. The test module calls the functions in turn,
// so the order of the lines is fixed. Icarus Verilog 13.0 does not know
// $timeunit.

module tu_100s;
  timeunit 100s;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module tu_10s;
  timeunit 10s;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module tu_1s;
  timeunit 1s;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module tu_100ms;
  timeunit 100ms;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module tu_10ms;
  timeunit 10ms;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module tu_1ms;
  timeunit 1ms;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module tu_100us;
  timeunit 100us;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module tu_10us;
  timeunit 10us;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module tu_1us;
  timeunit 1us;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module tu_100ns;
  timeunit 100ns;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module tu_10ns;
  timeunit 10ns;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module tu_1ns;
  timeunit 1ns;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module tu_100ps;
  timeunit 100ps;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module tu_10ps;
  timeunit 10ps;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module tu_1ps;
  timeunit 1ps;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module tu_100fs;
  timeunit 100fs;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module tu_10fs;
  timeunit 10fs;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module tu_1fs;
  timeunit 1fs;
  timeprecision 1fs;
  function int unit();
    return $timeunit;
  endfunction
endmodule

module test_timeunit_exponent_table;
  timeunit 1ns;
  timeprecision 1fs;

  tu_100s u_100s();
  tu_10s u_10s();
  tu_1s u_1s();
  tu_100ms u_100ms();
  tu_10ms u_10ms();
  tu_1ms u_1ms();
  tu_100us u_100us();
  tu_10us u_10us();
  tu_1us u_1us();
  tu_100ns u_100ns();
  tu_10ns u_10ns();
  tu_1ns u_1ns();
  tu_100ps u_100ps();
  tu_10ps u_10ps();
  tu_1ps u_1ps();
  tu_100fs u_100fs();
  tu_10fs u_10fs();
  tu_1fs u_1fs();

  initial begin
    $display("100s: %0d", u_100s.unit());
    $display("10s: %0d", u_10s.unit());
    $display("1s: %0d", u_1s.unit());
    $display("100ms: %0d", u_100ms.unit());
    $display("10ms: %0d", u_10ms.unit());
    $display("1ms: %0d", u_1ms.unit());
    $display("100us: %0d", u_100us.unit());
    $display("10us: %0d", u_10us.unit());
    $display("1us: %0d", u_1us.unit());
    $display("100ns: %0d", u_100ns.unit());
    $display("10ns: %0d", u_10ns.unit());
    $display("1ns: %0d", u_1ns.unit());
    $display("100ps: %0d", u_100ps.unit());
    $display("10ps: %0d", u_10ps.unit());
    $display("1ps: %0d", u_1ps.unit());
    $display("100fs: %0d", u_100fs.unit());
    $display("10fs: %0d", u_10fs.unit());
    $display("1fs: %0d", u_1fs.unit());
  end
endmodule
