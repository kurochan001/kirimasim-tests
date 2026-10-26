/*
:name: test_enum_reuse_next_prev_encoding
:description: a named enum type is reusable, next and prev step and wrap in declaration order, and an out-of-range value returns the default
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.19.1 6.19.5.3 6.19.5.4 6.19
:oracle: spec iverilog@13.0 verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_enum_reuse_next_prev_encoding.expected
*/
// IEEE 1800-2023 6.19.1: a typedef name makes one enum type reusable by every
// declaration that names it. 6.19.5.3 and 6.19.5.4: next()/prev() take an
// int unsigned count (default 1), step in declaration order, wrap at the ends,
// and return the enumeration default value when the current value is not a
// member. The test uses a bit-based enum so that the default value is 0 and
// the result is fully defined, and a second enum whose implicit increment
// wraps inside the base type (6.19, 6.20.2).

typedef enum bit [1:0] {RED = 2'd1, GREEN = 2'd2, BLUE = 2'd3} color_t;
typedef enum int {NEG = 32'hFFFF_FFFF, AFTER} post_t;

module test_enum_reuse_next_prev_encoding;
  color_t c1, c2;
  post_t w;
  int n;

  initial begin
    c1 = RED;
    c2 = c1;
    $display("reuse c1=%0d c2=%0d", c1, c2);
    $display("next=%0d", c1.next());
    $display("next2=%0d", c1.next(2));
    $display("prev=%0d", c1.prev());
    $display("prev2=%0d", c1.prev(2));
    c2 = BLUE;
    $display("wrap_next=%0d", c2.next());
    c2 = RED;
    $display("wrap_prev=%0d", c2.prev());
    c1 = color_t'(2'd0);
    $display("nonmember_next=%0d", c1.next());
    $display("nonmember_prev=%0d", c1.prev());
    w = NEG;
    $display("post_cast=%0d after=%0d", w, AFTER);
    c1 = RED;
    n = c1.next(3);
    $display("count3=%0d", n);
    n = c1.prev(3);
    $display("count3_prev=%0d", n);
  end
endmodule
