/*
:name: test_class_property_init_after_base_constructor
:description: class properties get their declared or default initial values after the base constructor returns and before the rest of the constructor runs (IEEE 1800-2023 Section 8.7)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.7 8.15
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_class_property_init_after_base_constructor.expected
*/
// IEEE 1800-2023 §8.7: a derived constructor first calls the base
// constructor (§8.15); after that call completes, each property of the class
// is set to its declared initial value, or to the uninitialized value of its
// type when it has none, and only then does the rest of the constructor run.
// base_c records its properties at the start of its constructor body: b1 is
// 10, b2 0, b3 x and b4 "init", and the body then sets b1 to 11. derived_c
// declares d1 = b1 + 1, which is initialized after super.new() has returned
// and so sees 11, and d2 = 7, which its constructor body reads before setting
// it to 8.

class base_c;
  int b1 = 10;
  int b2;
  logic [3:0] b3;
  string b4 = "init";
  int seen_b1, seen_b2;
  logic [3:0] seen_b3;
  string seen_b4;
  function new();
    seen_b1 = b1;
    seen_b2 = b2;
    seen_b3 = b3;
    seen_b4 = b4;
    b1 = 11;
  endfunction
endclass

class derived_c extends base_c;
  int d1 = b1 + 1;
  int d2 = 7;
  int seen_d2;
  function new();
    super.new();
    seen_d2 = d2;
    d2 = 8;
  endfunction
endclass

module test_class_property_init_after_base_constructor;
  derived_c d;

  initial begin
    d = new;
    $display("base body saw: b1=%0d b2=%0d b3=%b b4=%s", d.seen_b1, d.seen_b2, d.seen_b3,
             d.seen_b4);
    $display("after construction: b1=%0d d1=%0d seen_d2=%0d d2=%0d", d.b1, d.d1, d.seen_d2,
             d.d2);
  end
endmodule
