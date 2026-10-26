/*
:name: test_class_cast_compatibility_dynamic
:description: $cast between class handles succeeds only when the object is assignment compatible with the destination
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.24.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_cast_compatibility_dynamic.expected
*/
// IEEE 1800-2023 6.24.2: $cast as a function returns 1 when the assignment is
// valid and 0 when it is not, without an error, and the destination is left
// unchanged on failure. For singular arguments the assignment is valid only
// when the types are cast compatible (8.16). The test casts a base handle that
// refers to a base object to a derived handle (fails, destination unchanged),
// repeats it with a derived object (succeeds), and casts a class implementing
// one interface class to an unrelated interface class handle (fails).

class cast_base;
  int v;

  function new();
    v = 1;
  endfunction
endclass

class cast_derived extends cast_base;
  function new();
    super.new();
  endfunction
endclass

interface class iface_a;
  pure virtual function int fa();
endclass

interface class iface_b;
  pure virtual function int fb();
endclass

class impl_a implements iface_a;
  virtual function int fa();
    return 1;
  endfunction
endclass

module test_class_cast_compatibility_dynamic;
  cast_base a;
  cast_derived b;
  cast_derived saved;
  iface_a ia;
  iface_b ib;
  impl_a obj;

  initial begin
    a = new;
    b = new;
    b.v = 7;
    saved = b;
    $display("down_fail=%0d unchanged=%0d", $cast(b, a), b.v);
    a = b;
    $display("down_ok=%0d value=%0d", $cast(b, a), b.v);
    obj = new;
    ia = obj;
    $display("iface_ok=%0d", ia.fa());
    $display("iface_fail=%0d", $cast(ib, ia));
    $display("same=%0d", saved == b);
  end
endmodule
