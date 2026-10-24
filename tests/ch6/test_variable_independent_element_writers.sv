/*
:name: test_variable_independent_element_writers
:description: Different members of an unpacked structure, different elements of an unpacked array and different bits of a vector are separate elements, so each can have its own continuous assignment or procedural writes (IEEE 1800-2023 Section 6.5)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.5 11.5.3 10.3.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_variable_independent_element_writers.expected
*/
// IEEE 1800-2023 §6.5: assignments to independent elements of a variable are
// checked separately: different members of a structure, different elements of
// an array and each bit of a packed type are such elements. One element can
// be written continuously and another procedurally, and several elements can
// each have one continuous assignment (10.3.2). The longest static prefix of
// each assignment below (11.5.3) is a single member, element or bit, so no
// element has two continuous assignments or a mixture of writers.
// r.a and r.c have continuous assignments and r.b procedural writes; arr[0]
// and arr[2] have continuous assignments and arr[1] procedural writes; bits[0]
// and bits[1] have continuous assignments and bits[7:2] procedural writes.
// Each element shows its own writer's value, before and after the sources and
// the procedural values change.
// Oracle checks: Icarus Verilog 13.0 does not support unpacked structures; with
// a packed one it rejects the procedural write of r.b because r.a has a
// continuous assignment. The 5.052 release rejects the design with CONTASSINIT,
// taking the procedural writes of r.b and arr[1] for initial values of the
// whole of r and arr. Both rejections are wrong by 6.5, so the expected output
// follows the cited clauses alone.

module test_variable_independent_element_writers;
  typedef struct {
    logic [7:0] a;
    logic [7:0] b;
    logic [7:0] c;
  } rec_t;

  rec_t r;
  logic [7:0] arr [0:2];
  logic [7:0] bits;
  logic [7:0] src = 8'h5a;
  logic s0 = 1'b1, s1 = 1'b0;

  assign r.a = src;
  assign r.c = ~src;
  assign arr[0] = src + 8'd1;
  assign arr[2] = src - 8'd1;
  assign bits[0] = s0;
  assign bits[1] = s1;

  initial begin
    #1;
    r.b = 8'h01;
    arr[1] = 8'h02;
    bits[7:2] = 6'b101010;
    #1 $display("r: a=%h b=%h c=%h arr: %h %h %h bits=%b", r.a, r.b, r.c,
                arr[0], arr[1], arr[2], bits);
    src = 8'h0f;
    s0 = 1'b0;
    s1 = 1'b1;
    r.b = 8'h03;
    arr[1] = 8'h04;
    bits[7:2] = 6'b010101;
    #1 $display("r: a=%h b=%h c=%h arr: %h %h %h bits=%b", r.a, r.b, r.c,
                arr[0], arr[1], arr[2], bits);
  end
endmodule
