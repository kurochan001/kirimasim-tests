/*
:name: test_illegal_cg_cross_with_struct_result
:description: the with clause of a cross bin is an unpacked structure, which is not assignment compatible with an integral type (IEEE 1800-2023 Section 19.6)
:tags: ch19
:type: elaboration
:lrm: 1800-2023 19.6
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the with clause of the cross bin bad is the covergroup argument p, of the unpacked structure type pair_t
:expected_stderr_regex: test_illegal_cg_cross_with_struct_result\.sv:39:
*/
// IEEE 1800-2023 §19.6 (Syntax 19-4): the result of the with_covergroup_
// expression of a cross bin shall be assignment compatible with an integral
// type. An unpacked structure is assignment compatible only with an
// equivalent type (6.22.3), so it is not. The covergroup argument p is a
// non-ref argument, which a covergroup_expression may use as a variable. The
// bin ok uses the int members of p in a comparison, which is integral, and
// is legal; the bin bad uses p itself as the with expression, which is the
// one error. With p.lo in place of p in bad the design is legal.
//
// Oracle check: the 5.054 release of Verilator reports on the named line
// that the with filter is not assignment compatible with an integral type,
// and accepts the design with p.lo in place of p. Icarus Verilog 13.0 does
// not support unpacked structures or covergroups, so its errors are no
// evidence for the rule.

module test_illegal_cg_cross_with_struct_result;
  typedef struct { int lo; int hi; } pair_t;
  bit [1:0] a, b;
  pair_t init = '{1, 2};

  covergroup cg (input pair_t p);
    ca: coverpoint a;
    cb: coverpoint b;
    x: cross ca, cb {
      bins ok = x with (ca >= p.lo && cb <= p.hi);
      bins bad = x with (p);   // illegal: not integral
    }
  endgroup

  cg g;

  initial begin
    g = new(init);
    $display("not reached");
  end
endmodule
