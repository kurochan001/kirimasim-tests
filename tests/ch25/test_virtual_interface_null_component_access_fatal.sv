/*
:name: test_virtual_interface_null_component_access_fatal
:description: A virtual interface is null until it is assigned, and reading a component through a null virtual interface is a fatal run-time error that ends the simulation (IEEE 1800-2023 Section 25.9)
:tags: ch25
:type: simulation
:lrm: 1800-2023 25.9 6.8 20.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_virtual_interface_null_component_access_fatal.expected
:expected_stderr_regex: (?i:\b(?:fatal|error)\b)
*/
// IEEE 1800-2023 §25.9: a virtual interface has the value null until it is
// initialized, and it shall be initialized before a component is referenced
// through it; an attempt to use a null virtual interface shall result in a
// fatal run-time error. As for $fatal (20.10), a fatal error ends the
// simulation.
// - At 1 the test prints that vn is null and reads d through vok, which
//   refers to bus.
// - At 2 it reads d through vn, which was never assigned: the fatal error
//   ends the run, so the line after the read and the line that a second
//   process would print at 5 do not appear.
// The messages of the run are checked for a fatal error or an error, whose
// form the standard leaves to the tool; the exit code is not checked.
// Icarus Verilog 13.0 does not support virtual interfaces. Verilator 5.052
// prints the two lines and ends the run with an error, but it prints the
// error on standard output, so its output differs.

`timescale 1ns/1ns

interface vnf_if;
  logic [3:0] d = 4'h5;
endinterface

module test_virtual_interface_null_component_access_fatal;
  vnf_if bus ();
  virtual vnf_if vok, vn;
  logic [3:0] x;

  initial begin
    vok = bus;
    #1 $display("t=%0t vn is null: %0d, vok.d=%h", $time, vn == null, vok.d);
    #1 $display("t=%0t reading vn.d", $time);
    x = vn.d;
    $display("t=%0t after the read: x=%h", $time, x);
  end

  initial #5 $display("t=%0t still running", $time);
endmodule
