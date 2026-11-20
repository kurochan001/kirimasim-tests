/*
:name: test_illegal_super_new_default_with_extends_default
:description: When the extends specifier has default as its sole argument, the subclass constructor gets super.new(default) from it and shall not call super.new itself, not even as super.new(default) (IEEE 1800-2023 Section 8.17)
:tags: ch8
:type: elaboration
:lrm: 1800-2023 8.17
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: sx_bad_c extends sx_base_c(default), so its constructor shall not contain a super.new call, but it calls super.new(default)
:expected_stderr_regex: test_illegal_super_new_default_with_extends_default\.sv:50:
*/
// IEEE 1800-2023 §8.17: when arguments are specified in the extends
// specifier, the subclass constructor shall not contain a super.new() call;
// the compiler inserts it. default may be the sole argument of the extends
// specifier, and then a user-defined constructor of the subclass has default
// in its argument list and gets the call super.new(default) from the extends
// specifier. sx_ok_c does that without a call of its own; sx_also_c has no
// argument in its extends specifier and calls super.new(default) itself. Both
// are legal; sx_bad_c has default in its extends specifier and also calls
// super.new(default). Without the marked call the design is legal and prints
// 4 2 6.
// Neither Icarus Verilog 13.0 nor the 5.054 release of Verilator supports
// default in a constructor argument list or an extends specifier; the errors
// they report for that, also on the marked line, do not count.

class sx_base_c;
  int a;
  function new(int a = 1);
    this.a = a;
  endfunction
endclass

class sx_ok_c extends sx_base_c(default);
  int b;
  function new(default, int b = 2);
    this.b = b;
  endfunction
endclass

class sx_also_c extends sx_base_c;
  function new(default);
    super.new(default);
  endfunction
endclass

class sx_bad_c extends sx_base_c(default);
  function new(default);
    super.new(default);   // illegal: the extends specifier already gives default
  endfunction
endclass

module test_illegal_super_new_default_with_extends_default;
  sx_ok_c o;
  sx_also_c s;
  sx_bad_c x;
  initial begin
    o = new(4);
    s = new(6);
    x = new(8);
    $display("%0d %0d %0d", o.a, o.b, s.a);
  end
endmodule
