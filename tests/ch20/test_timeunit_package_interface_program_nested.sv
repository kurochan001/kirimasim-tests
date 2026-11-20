/*
:name: test_timeunit_package_interface_program_nested
:description: $timeunit and $timeprecision give the values of the package, interface or program whose scope calls them, an interface instance named as the argument gives those of the interface, and a nested module without its own declarations gives those it inherits from the enclosing module (IEEE 1800-2023 Sections 20.4.1, 3.14.2.3)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.4.1 3.14.2.2 3.14.2.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_timeunit_package_interface_program_nested.expected
*/
// IEEE 1800-2023 §20.4.1: without an argument, $timeunit and $timeprecision
// give the time unit and precision of the design element of the current
// scope, and with an argument those of the design element it names; the
// values are the exponents of Table 20-2. §3.14.2.2: a module, program,
// package or interface declares its own with timeunit and timeprecision.
// §3.14.2.3: a nested module without them inherits those of the enclosing
// module.
// - The function of tu_pkg (10 us / 100 ns) gives -5 -7.
// - $timeunit(ifc) and $timeprecision(ifc) for the instance of tu_if
//   (100 ps / 10 fs) give -10 -14, and so does the function of tu_if.
// - The top module (1 ns / 1 ps) gives -9 -12, and the nested module inner,
//   which declares nothing, the same values through its instance and its own
//   function.
// - The program tu_prog (1 ms / 10 us) prints -3 -5 after #1, one of its own
//   time units, when the lines of the module are already printed.
// Neither Icarus Verilog 13.0 nor the 5.054 release of Verilator supports a
// module declared in a module, and Icarus Verilog does not know $timeunit,
// so the expected output follows the cited clauses.

package tu_pkg;
  timeunit 10us;
  timeprecision 100ns;
  function automatic string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endpackage

interface tu_if;
  timeunit 100ps;
  timeprecision 10fs;
  function automatic string show();
    return $sformatf("%0d %0d", $timeunit, $timeprecision);
  endfunction
endinterface

program tu_prog;
  timeunit 1ms;
  timeprecision 10us;
  initial begin
    #1;
    $display("program: %0d %0d", $timeunit, $timeprecision);
  end
endprogram

module test_timeunit_package_interface_program_nested;
  timeunit 1ns;
  timeprecision 1ps;

  module inner;
    function automatic string show();
      return $sformatf("%0d %0d", $timeunit, $timeprecision);
    endfunction
  endmodule

  tu_if ifc ();
  tu_prog prg ();
  inner n ();

  initial begin
    $display("package: %s", tu_pkg::show());
    $display("interface: %0d %0d, own function: %s", $timeunit(ifc), $timeprecision(ifc),
             ifc.show());
    $display("top: %0d %0d", $timeunit, $timeprecision);
    $display("nested: %0d %0d, own function: %s", $timeunit(n), $timeprecision(n), n.show());
  end
endmodule
