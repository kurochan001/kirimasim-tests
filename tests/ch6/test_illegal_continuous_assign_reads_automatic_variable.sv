/*
:name: test_illegal_continuous_assign_reads_automatic_variable
:description: A continuous assignment cannot reference an automatic variable, even one declared in a named block of a static initial procedure, since such references are limited to procedural blocks (IEEE 1800-2023 Section 6.21)
:tags: ch6
:type: elaboration
:lrm: 1800-2023 6.21
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:should_fail_because: the continuous assignment to w reads blk.count, an automatic variable of the named block blk, outside a procedural block
:expected_stderr_regex: test_illegal_continuous_assign_reads_automatic_variable\.sv:33:
*/
// IEEE 1800-2023 §6.21: references to automatic variables shall be limited
// to procedural blocks. The initial procedure is static, but its named block
// blk declares count with the automatic keyword, so count lives only while
// the block runs and is initialized on each entry. A continuous assignment
// is not a procedural block, so the assignment to w on the marked line, which
// reads count through the name of the block, is illegal. Objects of automatic
// tasks and functions also cannot be named hierarchically (§23.6), but blk is
// a block of a static procedure, so only the rule of §6.21 applies here.
// Without the continuous assignment, the design is legal.
// Oracle check: Icarus Verilog 13.0 stops at the declaration of count, which
// it reports as not supported yet, so its error is not a diagnosis of this
// rule; the 5.054 release of Verilator accepts the design.

module test_illegal_continuous_assign_reads_automatic_variable;
  wire [31:0] w;
  initial begin : blk
    automatic int count = 5;
    #1 $display("count=%0d", count);
  end
  assign w = blk.count;    // illegal: automatic variable outside a procedure
endmodule
