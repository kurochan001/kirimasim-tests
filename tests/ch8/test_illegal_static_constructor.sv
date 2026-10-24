/*
:name: test_illegal_static_constructor
:description: a constructor cannot be declared static (IEEE 1800-2023 Section 8.7)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.7 8.10
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the constructor new of item_c is declared static
:expected_stderr_regex: test_illegal_static_constructor\.sv:31:
*/
// IEEE 1800-2023 §8.7: a constructor may be local or protected, but it shall
// not be declared static (8.10) or virtual (8.20). shared_c has a protected
// constructor, which is legal; item_c declares its constructor static.
// Icarus Verilog 13.0 accepts the static constructor; its only error is on the
// call shared_c::get(), which it does not parse.

class shared_c;
  static shared_c one;
  protected function new();
  endfunction
  static function shared_c get();
    if (one == null) one = new;
    return one;
  endfunction
endclass

class item_c;
  static function new();   // illegal: static constructor
  endfunction
endclass

module test_illegal_static_constructor;
  shared_c s;
  initial begin
    s = shared_c::get();
    $display("%0d", s != null);
  end
endmodule
