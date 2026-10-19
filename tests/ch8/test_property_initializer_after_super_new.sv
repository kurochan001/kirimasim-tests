/*
:name: test_property_initializer_after_super_new
:description: The initializers of a derived class's properties run after the base class constructor and before the rest of the derived constructor (IEEE 1800-2023 Section 8.7)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.7 8.17
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_initializer_after_super_new.expected
*/
// IEEE 1800-2023 §8.7: a constructor first calls the constructor of the
// base class, then initializes each property of its own class to its
// default value, and only then runs the rest of its body (8.17 describes the
// chain). So an initializer "int c = b + 2" in a derived class sees the
// value that the base class constructor gave b, and the derived constructor
// body sees c already set.

class base_part;
  int b = 1;
  function new();
    b = b + 40;
  endfunction
endclass

class derived_part extends base_part;
  int c = b + 2;
  int seen_c;
  function new();
    super.new();
    seen_c = c;
    c = c * 10;
  endfunction
endclass

module test_property_initializer_after_super_new;
  derived_part d;

  initial begin
    d = new;
    $display("b=%0d seen_c=%0d c=%0d", d.b, d.seen_c, d.c);
  end
endmodule
