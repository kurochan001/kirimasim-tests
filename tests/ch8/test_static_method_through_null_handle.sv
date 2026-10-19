/*
:name: test_static_method_through_null_handle
:description: A static method and a static property can be used through a class handle that is null (IEEE 1800-2023 Section 8.10)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.10 8.9 8.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_static_method_through_null_handle.expected
*/
// IEEE 1800-2023 §8.10: a static method can be called without any object
// of its class, and §8.9: so can a static property be used. §8.4 makes only
// the access to non-static members (and virtual methods) through a null
// handle illegal, so a static method or property named through a handle
// that is still null is used as through the class name.

class leaf;
  static int calls = 0;
  static function int ping();
    calls++;
    return 37;
  endfunction
endclass

module test_static_method_through_null_handle;
  leaf obj;
  int r;

  initial begin
    $display("obj == null: %0d", obj == null);
    r = obj.ping();
    $display("obj.ping() = %0d", r);
    r = leaf::ping();
    $display("leaf::ping() = %0d", r);
    $display("obj.calls = %0d", obj.calls);
  end
endmodule
