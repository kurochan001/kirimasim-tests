/*
:name: test_class_shallow_copy_members_type_no_constructor
:description: new followed by a handle makes a distinct object of the dynamic class of the source, without running its constructor or declaration initializers, copies every property and shares the objects that handle properties refer to (IEEE 1800-2023 Section 8.12)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.12
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_shallow_copy_members_type_no_constructor.expected
*/
// IEEE 1800-2023 §8.12: new h makes a shallow copy of the object h refers to.
// An object of the class being copied is allocated without calling its
// constructor and without running declaration initializers, all properties
// are copied, and handles are copied, not the objects they refer to, even
// when the property was declared with new. The copy has the class of the
// object, even when the handle variables have a base class type.
// ctor_calls counts calls of the constructor of rec_c and init_calls the
// evaluations of the initializer of i; neither changes when b and c are made
// by copying. Changes to b do not reach a, except through the shared inner
// object. c is copied through a rec_c handle that holds an ext_c object, so
// its virtual method kind() and the property extra show that c is an ext_c.
// Icarus Verilog 13.0 does not support queues inside classes.

module test_class_shallow_copy_members_type_no_constructor;
  int ctor_calls = 0;
  int init_calls = 0;

  function automatic int note_init();
    init_calls++;
    return 7;
  endfunction

  class inner_c;
    int j = 5;
  endclass

  class rec_c;
    int i = note_init();
    string s;
    int q[$];
    inner_c in = new;
    function new();
      ctor_calls++;
      s = "made";
      q = '{1, 2};
    endfunction
    virtual function string kind();
      return "rec";
    endfunction
  endclass

  class ext_c extends rec_c;
    int extra = 9;
    virtual function string kind();
      return "ext";
    endfunction
  endclass

  rec_c a, b, base_h, c;
  ext_c e, e2;

  initial begin
    a = new;
    b = new a;
    $display("after copy: ctor_calls=%0d init_calls=%0d", ctor_calls, init_calls);
    b.i = 70;
    b.s = "copy";
    b.q.push_back(3);
    b.in.j = 50;
    $display("a: i=%0d s=%s q size=%0d in.j=%0d", a.i, a.s, a.q.size(), a.in.j);
    $display("b: i=%0d s=%s q size=%0d in.j=%0d", b.i, b.s, b.q.size(), b.in.j);
    $display("distinct objects=%0d shared inner=%0d", a != b, a.in == b.in);
    e = new;
    e.extra = 99;
    base_h = e;
    c = new base_h;
    $display("after second copy: ctor_calls=%0d init_calls=%0d", ctor_calls, init_calls);
    $display("c: kind=%s distinct=%0d cast=%0d", c.kind(), c != base_h, $cast(e2, c));
    $display("c: extra=%0d", e2.extra);
  end
endmodule
