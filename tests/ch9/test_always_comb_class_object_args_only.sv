/*
:name: test_always_comb_class_object_args_only
:description: an always_comb that calls a method of a class object and reads a member of it is not sensitive to the members or to the handle, only to the argument passed to the method (IEEE 1800-2023 Section 9.2.2.2.1)
:tags: ch9
:type: simulation
:lrm: 1800-2023 9.2.2.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_always_comb_class_object_args_only.expected
*/
// IEEE 1800-2023 §9.2.2.2.1: references to class objects and calls of their
// methods add nothing to the implicit sensitivity of always_comb, except
// what the argument expressions passed to the methods contribute.
//
// The block computes y = obj.get(arg), where get returns the member m plus
// its argument, and z = obj.m; if the block ran, y and z would show the
// current values. After the run at time 0:
//   obj.m = 5      does not run the block: y and z keep 1 and 0
//   obj = other    (other.m is 100) does not run it either
//   arg = 2        runs it: y = other.m + 2 = 102, z = 100
//
// Icarus Verilog 13.0 runs the block again when the handle obj changes, and
// the 5.052 release of Verilator when the member obj.m changes.

module test_always_comb_class_object_args_only;
  class C;
    int m;
    function int get(int x);
      return m + x;
    endfunction
  endclass

  C obj = new;
  C other = new;
  int arg = 1, y, z;

  always_comb begin
    y = obj.get(arg);
    z = obj.m;
  end

  initial begin
    other.m = 100;
    #1 $display("start:       y=%0d z=%0d", y, z);
    obj.m = 5;
    #1 $display("obj.m = 5:   y=%0d z=%0d", y, z);
    obj = other;
    #1 $display("obj = other: y=%0d z=%0d", y, z);
    arg = 2;
    #1 $display("arg = 2:     y=%0d z=%0d", y, z);
  end
endmodule
