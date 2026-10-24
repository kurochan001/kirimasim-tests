/*
:name: test_alias_bidirectional_shared_drivers
:description: the names joined by alias are one net, so the drivers of every name are resolved together and each name reads the resolved value and strength, also for aliased bits of a wider net (IEEE 1800-2023 Section 10.11)
:tags: ch10
:type: simulation
:lrm: 1800-2023 10.11 21.2.1.4
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_alias_bidirectional_shared_drivers.expected
*/
// IEEE 1800-2023 §10.11: an alias does not copy one name into another, as a
// continuous assignment does in one direction, possibly with a delay and a
// new strength; the names of an alias are the same physical net, or the same
// bits of a net. So the drivers of all the names act on one net, and every
// name shows the value and strength resolved from all of them.
// a = b: a strong 0 on a and a weak 1 on b give St0 on both names. c = d has
// the strong 0 on the second name instead, and gives St0 on both too. A copy
// from one name to the other would leave one of the two pairs with the weak 1
// or with a strong conflict. e = f has only a weak 1 on e, and f shows that
// weak strength (§21.2.1.4, %v), not the strong drive of an assignment. g = h
// has no driver, and both names are high impedance. w[5:2] = n joins four bits
// of w to n: w[7:4] and n[1:0] are driven, so n reads w[5:4] in its upper
// bits, w reads n[1:0] in w[3:2], and w[1:0], not joined and not driven, are z.
// Neither Icarus Verilog 13.0 (no alias statement) nor Verilator 5.052 (no
// strengths, no alias of a part-select) can run this test.

module test_alias_bidirectional_shared_drivers;
  wire a, b, c, d, e, f, g, h;
  wire [7:0] w;
  wire [3:0] n;

  alias a = b;
  assign (strong0, strong1) a = 1'b0;
  assign (weak0, weak1) b = 1'b1;

  alias c = d;
  assign (weak0, weak1) c = 1'b1;
  assign (strong0, strong1) d = 1'b0;

  alias e = f;
  assign (weak0, weak1) e = 1'b1;

  alias g = h;

  alias w[5:2] = n;
  assign w[7:4] = 4'b1010;
  assign n[1:0] = 2'b11;

  initial begin
    #1;
    $display("a=%v b=%v", a, b);
    $display("c=%v d=%v", c, d);
    $display("e=%v f=%v", e, f);
    $display("g=%v h=%v", g, h);
    $display("w=%b n=%b", w, n);
  end
endmodule
