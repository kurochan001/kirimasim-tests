/*
:name: test_assignment_like_subroutine_arguments
:description: passing a value to a subroutine input, output or inout argument is an assignment-like context, so an input takes an assignment pattern or an unpacked array concatenation of the formal's type and an output or inout actual can be a positional assignment pattern of variables, also for a formal of an unpacked array type (IEEE 1800-2023 Section 10.8)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.8 10.9 10.10
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_assignment_like_subroutine_arguments.expected
*/
// IEEE 1800-2023 §10.8: passing a value to a subroutine input, output or
// inout argument is an assignment-like context. §10.9: an assignment pattern
// without a type takes its type from the other side, and as the left-hand
// side it lists variables by position whose widths match the elements.
// §10.10: braces with an unpacked array target are an unpacked array
// concatenation. §13.5: the actual of an output or inout argument is an
// expression that is legal on the left-hand side of a procedural
// assignment, and the values are copied back when the subroutine returns.
// pair_t is a packed structure of two 8-bit members. A pattern of two ints
// gives one int to each member; as a vector concatenation it would be 64
// bits cut to 16, with hi = 0.
//   - input: weigh('{three, four}) receives hi = 3 and lo = 4, and count_all
//     receives the braces as a queue of three elements.
//   - output: swap_out writes the swapped pair to '{h1, l1}, so h1 gets the
//     hi member (4) and l1 the lo member (3); split writes an unpacked array
//     of two elements to '{e0, e1}, element 0 to e0.
//   - inout: bump receives '{h2, l2} = 20 and 30 as a pair, adds 1 and 10,
//     and copies 21 and 40 back to h2 and l2. On the packed pair_t such a
//     pattern has the same bits as a concatenation of the two variables, so
//     the task rotate also takes an inout unpacked array of three bytes:
//     '{r0, r1, r2} = 20, 30 and 40 is copied in as elements 0 to 2, rotate
//     makes them 30, 40 and 20 + 100, and they are copied back by position.
//     Only a pattern fits there: a 24-bit vector and an unpacked array are
//     not assignment compatible (§7.6).
// Icarus Verilog 13.0 rejects function arguments that are not inputs and
// patterns as task output actuals ("l-value too complex"); §13.4 allows
// output and inout function arguments.

typedef struct packed {
  logic [7:0] hi;
  logic [7:0] lo;
} pair_t;

module test_assignment_like_subroutine_arguments;
  int three = 3, four = 4;
  logic [7:0] h1, l1, h2, l2, e0, e1, r0, r1, r2;

  function automatic int weigh(input pair_t p);
    return p.hi * 100 + p.lo;
  endfunction

  function automatic int count_all(input logic [7:0] items [$]);
    return items.size() * 100 + items[0] * 10 + items[$];
  endfunction

  task automatic swap_out(input pair_t src, output pair_t dst);
    dst = '{src.lo, src.hi};
  endtask

  function automatic void split(input int base, output logic [7:0] parts [2]);
    parts = '{base + 1, base + 2};
  endfunction

  function automatic void bump(inout pair_t p);
    p = '{p.hi + 8'd1, p.lo + 8'd10};
  endfunction

  task automatic rotate(inout logic [7:0] items [3]);
    logic [7:0] old [3];
    old = items;
    items = '{old[1], old[2], old[0] + 8'd100};
  endtask

  initial begin
    $display("input pattern: %0d", weigh('{three, four}));
    $display("input braces: %0d", count_all({8'd1, 8'd2, 8'd3}));
    swap_out('{three, four}, '{h1, l1});
    $display("output pattern: h1=%0d l1=%0d", h1, l1);
    split(50, '{e0, e1});
    $display("output array pattern: e0=%0d e1=%0d", e0, e1);
    h2 = 8'd20;
    l2 = 8'd30;
    bump('{h2, l2});
    $display("inout pattern: h2=%0d l2=%0d", h2, l2);
    r0 = 8'd20;
    r1 = 8'd30;
    r2 = 8'd40;
    rotate('{r0, r1, r2});
    $display("inout array pattern: r0=%0d r1=%0d r2=%0d", r0, r1, r2);
  end
endmodule
