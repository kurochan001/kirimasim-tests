/*
:name: test_class_handle_argument_directions
:description: a class variable holds a handle to an object with properties and methods, and an object passed as an input, output, inout or ref argument passes its handle, not a copy of the object (IEEE 1800-2023 Sections 8.2, 6.15)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.2 6.15
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_handle_argument_directions.expected
*/
// IEEE 1800-2023 §8.2: a class is a type whose members are its data, the
// class properties, and its methods, the functions and tasks that operate on
// them; objects are referred to through handles, and when an object is an
// argument with the direction input, output, inout or ref, what the argument
// copies is the handle, not the contents of the object. §6.15: a class
// variable holds a handle to a class object.
// - a and keep hold handles to the same object, so a change through one is
//   seen through the other, and a == keep.
// - by_input changes the property val of the object through its input
//   argument, which the caller sees, and then makes the argument refer to a
//   new object, which the caller does not see.
// - by_output gives b a handle to a new object.
// - by_inout changes the object through its argument and then makes the
//   argument refer to a new object; the handle copied back on return makes a
//   refer to it, while keep still sees the old object with the change.
// - by_ref makes the referenced variable a refer to a new object at once.
// - The task bump and the function twice of the class change and read val.
// Icarus Verilog 13.0 does not support ref arguments ("Reference ports not
// supported yet").

module test_class_handle_argument_directions;
  class obj_c;
    int val;
    function new(int v);
      val = v;
    endfunction
    function int twice();
      return 2 * val;
    endfunction
    task bump();
      val++;
    endtask
  endclass

  obj_c a, b, keep;

  task automatic by_input(input obj_c h);
    h.val = 10;
    h = new(99);
  endtask

  task automatic by_output(output obj_c h);
    h = new(20);
  endtask

  task automatic by_inout(inout obj_c h);
    h.val += 1;
    h = new(30);
  endtask

  task automatic by_ref(ref obj_c h);
    h = new(40);
  endtask

  initial begin
    a = new(1);
    keep = a;
    keep.val = 5;
    $display("shared: a.val=%0d same=%0d", a.val, a == keep);
    by_input(a);
    $display("input: a.val=%0d keep.val=%0d same=%0d", a.val, keep.val, a == keep);
    by_output(b);
    $display("output: b.val=%0d", b.val);
    by_inout(a);
    $display("inout: a.val=%0d keep.val=%0d same=%0d", a.val, keep.val, a == keep);
    a = keep;
    by_ref(a);
    $display("ref: a.val=%0d keep.val=%0d same=%0d", a.val, keep.val, a == keep);
    keep.bump();
    $display("methods: val=%0d twice=%0d", keep.val, keep.twice());
  end
endmodule
