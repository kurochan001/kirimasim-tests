/*
:name: test_const_runtime_automatic_and_class_handle
:description: a const in an automatic task gets a new value from any expression on each call during simulation, and a const class handle refers to an object whose members can still be written (IEEE 1800-2023 Section 6.20.6)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.20.6 8.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_const_runtime_automatic_and_class_handle.expected
*/
// IEEE 1800-2023 §6.20.6: unlike a localparam, which is set at elaboration,
// a const can get its value during simulation, as in an automatic task, and
// an automatic const can be set to any expression that is legal without
// const: here an argument, $time plus a module variable that changes between
// the calls, and a string from $sformatf. Each call of the task sets the
// consts anew. A class handle can be declared const (here initialized with
// new, §8.7); the object acts like a variable that cannot be written, but
// its members can be written. Icarus Verilog 13.0 rejects the write of the
// member obj.n ("Assignment to const signal").

`timescale 1ns/1ns
module test_const_runtime_automatic_and_class_handle;
  class counter_c;
    int n;
    function new(int start);
      n = start;
    endfunction
  endclass

  int base = 10;
  const counter_c obj = new(5);

  task automatic record(int x);
    const int doubled = x * 2;
    const int stamp = $time + base;
    const string tag = $sformatf("x%0d", x);
    $display("t=%0t doubled=%0d stamp=%0d tag=%s", $time, doubled, stamp, tag);
  endtask

  initial begin
    record(3);
    base = 20;
    #5 record(7);
    obj.n = obj.n + 1;
    obj.n++;
    $display("obj.n=%0d", obj.n);
  end
endmodule
