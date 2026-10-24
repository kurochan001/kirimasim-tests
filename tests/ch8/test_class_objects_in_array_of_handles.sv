/*
:name: test_class_objects_in_array_of_handles
:description: class variables start as null and hold handles to objects created at run time with new; copying a handle shares the object, and methods are called through the handles (IEEE 1800-2023 Sections 8.2, 6.15)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.2 6.15
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_objects_in_array_of_handles.expected
*/
// IEEE 1800-2023 §8.2: objects of a class are created dynamically and are
// passed around through object handles; the members of a class are its
// properties and its methods. §6.15: a class variable holds a handle to a
// class object.
// - The array pool of three class variables starts with null handles.
// - A loop creates a new object for each element, each with its own val:
//   the handles differ and the values are 0 10 20.
// - Copying pool[0] to pool[2] makes both refer to one object: a change of
//   val through pool[2] is seen through pool[0], and pool[2] == pool[0].
// - The method twice is called through pool[1] and pool[2].
// Icarus Verilog 13.0 rejects the assignment to a property through an element
// of an array of class handles (pool[2].val = 7).

module test_class_objects_in_array_of_handles;
  class obj_c;
    int val;
    function new(int v);
      val = v;
    endfunction
    function int twice();
      return 2 * val;
    endfunction
  endclass

  obj_c pool [3];

  initial begin
    $display("null: %0d %0d %0d", pool[0] == null, pool[1] == null, pool[2] == null);
    foreach (pool[i]) pool[i] = new(10 * i);
    $display("created: %0d %0d %0d differ=%0d", pool[0].val, pool[1].val, pool[2].val,
             pool[0] != pool[1]);
    pool[2] = pool[0];
    pool[2].val = 7;
    $display("shared: %0d same=%0d", pool[0].val, pool[2] == pool[0]);
    $display("methods: %0d %0d", pool[1].twice(), pool[2].twice());
  end
endmodule
