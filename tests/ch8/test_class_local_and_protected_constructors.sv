/*
:name: test_class_local_and_protected_constructors
:description: a constructor can be declared local, and then be called by a static method of its class, or protected, and then be called by the constructor of a derived class with super.new (IEEE 1800-2023 Section 8.7)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.7 8.18
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_local_and_protected_constructors.expected
*/
// IEEE 1800-2023 §8.7: a constructor may be declared as a local or protected
// method (§8.18). made_c has a local constructor, so objects of it are created
// inside the class, by its static method make; kid_c extends half_c, whose
// protected constructor it calls with super.new. The printed values show that
// both constructors ran with their arguments.
// Icarus Verilog 13.0 does not parse the call made_c::make(3) of a static
// method through the class scope.

class made_c;
  int v;
  local function new(int v);
    this.v = v;
  endfunction
  static function made_c make(int v);
    made_c m = new(v);
    return m;
  endfunction
endclass

class half_c;
  int h;
  protected function new(int h);
    this.h = h;
  endfunction
endclass

class kid_c extends half_c;
  function new();
    super.new(6);
  endfunction
endclass

module test_class_local_and_protected_constructors;
  made_c m;
  kid_c k;

  initial begin
    m = made_c::make(3);
    k = new;
    $display("local constructor: v=%0d; protected constructor: h=%0d", m.v, k.h);
  end
endmodule
