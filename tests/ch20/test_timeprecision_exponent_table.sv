/*
:name: test_timeprecision_exponent_table
:description: $timeprecision gives for each of the 18 possible time precisions, from 100 s down to 1 fs, the integer of Table 20-2, from 2 down to -15, also when the precision equals a time unit of 100 s (IEEE 1800-2023 Section 20.4.1)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.4.1 3.14.2.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeprecision_exponent_table.expected
*/
// IEEE 1800-2023 §20.4.1: $timeprecision returns the time precision of a
// design element as an integer from 2 down to -15, the power of ten of the
// precision in seconds that Table 20-2 gives, and $timeunit the time unit in
// the same way; without an argument they give the values of the design
// element of the current scope. §3.14.2.2: timeunit and timeprecision declare
// them, and the precision may not be coarser than the unit. Each module below
// has the time unit 100 s, the coarsest one, and one of the 18 precisions,
// from 100 s itself down to 1 fs, and a function that returns $timeunit and
// $timeprecision; inside the function the current scope belongs to that
// module. The test module calls the functions in turn, so the order of the
// lines is fixed, and each line shows 2 and the value of Table 20-2.
// Icarus Verilog 13.0 does not know $timeunit, and the 5.054 release of
// the simulator named Verilator gives the simulation precision, -15, for
// every $timeprecision, so the expected output follows the cited clauses.

module tp_100s;
  timeunit 100s;
  timeprecision 100s;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module tp_10s;
  timeunit 100s;
  timeprecision 10s;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module tp_1s;
  timeunit 100s;
  timeprecision 1s;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module tp_100ms;
  timeunit 100s;
  timeprecision 100ms;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module tp_10ms;
  timeunit 100s;
  timeprecision 10ms;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module tp_1ms;
  timeunit 100s;
  timeprecision 1ms;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module tp_100us;
  timeunit 100s;
  timeprecision 100us;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module tp_10us;
  timeunit 100s;
  timeprecision 10us;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module tp_1us;
  timeunit 100s;
  timeprecision 1us;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module tp_100ns;
  timeunit 100s;
  timeprecision 100ns;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module tp_10ns;
  timeunit 100s;
  timeprecision 10ns;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module tp_1ns;
  timeunit 100s;
  timeprecision 1ns;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module tp_100ps;
  timeunit 100s;
  timeprecision 100ps;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module tp_10ps;
  timeunit 100s;
  timeprecision 10ps;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module tp_1ps;
  timeunit 100s;
  timeprecision 1ps;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module tp_100fs;
  timeunit 100s;
  timeprecision 100fs;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module tp_10fs;
  timeunit 100s;
  timeprecision 10fs;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module tp_1fs;
  timeunit 100s;
  timeprecision 1fs;
  function string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endmodule

module test_timeprecision_exponent_table;
  timeunit 100s;
  timeprecision 1fs;
  tp_100s u_100s();
  tp_10s u_10s();
  tp_1s u_1s();
  tp_100ms u_100ms();
  tp_10ms u_10ms();
  tp_1ms u_1ms();
  tp_100us u_100us();
  tp_10us u_10us();
  tp_1us u_1us();
  tp_100ns u_100ns();
  tp_10ns u_10ns();
  tp_1ns u_1ns();
  tp_100ps u_100ps();
  tp_10ps u_10ps();
  tp_1ps u_1ps();
  tp_100fs u_100fs();
  tp_10fs u_10fs();
  tp_1fs u_1fs();

  initial begin
    $display("100s: %s", u_100s.show());
    $display("10s: %s", u_10s.show());
    $display("1s: %s", u_1s.show());
    $display("100ms: %s", u_100ms.show());
    $display("10ms: %s", u_10ms.show());
    $display("1ms: %s", u_1ms.show());
    $display("100us: %s", u_100us.show());
    $display("10us: %s", u_10us.show());
    $display("1us: %s", u_1us.show());
    $display("100ns: %s", u_100ns.show());
    $display("10ns: %s", u_10ns.show());
    $display("1ns: %s", u_1ns.show());
    $display("100ps: %s", u_100ps.show());
    $display("10ps: %s", u_10ps.show());
    $display("1ps: %s", u_1ps.show());
    $display("100fs: %s", u_100fs.show());
    $display("10fs: %s", u_10fs.show());
    $display("1fs: %s", u_1fs.show());
  end
endmodule
