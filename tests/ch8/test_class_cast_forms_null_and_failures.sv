/*
:name: test_class_cast_forms_null_and_failures
:description: $cast on class handles, called as a function or as a task with the destination first, succeeds and assigns for an upcast, for a downcast of a handle to a derived object and for the literal null, and as a function fails with 0 and no assignment otherwise, also for a null handle of an unrelated class (IEEE 1800-2023 Section 8.16)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.16 6.24.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_cast_forms_null_and_failures.expected
*/
// IEEE 1800-2023 §8.16: $cast(dest, source) is a function returning int or a
// task. On class handles it succeeds only when the destination type is the
// source type or a superclass of it, when the source type is a superclass of
// the destination type and the source refers to an object that can be
// assigned to the destination, or when the source is the literal null. In all
// other cases it fails, also when the source and destination types are not
// cast compatible and the source is null. A successful $cast assigns the
// handle; §6.24.2: a failing $cast called as a function returns 0 and leaves
// the destination unchanged. The test never lets the task form fail, which
// would be a run-time error.
// dh2 is set to a known handle before each cast, so the printed comparisons
// show whether the cast assigned it.
// Icarus Verilog 13.0 supports neither $cast nor comparisons of class handles.

module test_class_cast_forms_null_and_failures;
  class base_c;
    int b = 1;
  endclass
  class der_c extends base_c;
    int d = 2;
  endclass
  class other_c;
    int o = 3;
  endclass

  base_c bh, bh2;
  der_c dh, dh2;
  other_c oh;
  int ok;

  initial begin
    dh = new;
    dh.d = 22;
    bh = dh;
    ok = $cast(dh2, bh);
    $display("downcast function: ok=%0d same=%0d d=%0d", ok, dh2 == dh, dh2.d);
    dh2 = null;
    $cast(dh2, bh);
    $display("downcast task: same=%0d", dh2 == dh);
    ok = $cast(bh2, dh);
    $display("upcast function: ok=%0d same=%0d", ok, bh2 == dh);
    dh2 = dh;
    ok = $cast(dh2, null);
    $display("literal null: ok=%0d now null=%0d", ok, dh2 == null);
    bh = new;
    dh2 = dh;
    ok = $cast(dh2, bh);
    $display("base object: ok=%0d unchanged=%0d", ok, dh2 == dh);
    oh = null;
    dh2 = dh;
    ok = $cast(dh2, oh);
    $display("unrelated null handle: ok=%0d unchanged=%0d", ok, dh2 == dh);
  end
endmodule
