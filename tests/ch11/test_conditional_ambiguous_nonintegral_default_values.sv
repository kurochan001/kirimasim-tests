/*
:name: test_conditional_ambiguous_nonintegral_default_values
:description: with an x or z condition and unequal branches that are not integral and not same-length non-associative arrays, ?: gives the Table 7-1 value of its result type (IEEE 1800-2023 Section 11.4.11)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.4.11
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_conditional_ambiguous_nonintegral_default_values.expected
*/
// IEEE 1800-2023 §11.4.11: when the condition is x or z and the branches are
// not logically equivalent, nonintegral and aggregate branches are not
// combined bit by bit. Arrays other than associative arrays with the same
// number of elements are combined element by element; every other type gives
// the value that Table 7-1 (§7.4.5) lists for the result type: 0.0 for real
// and shortreal, "" for a string, null for a class handle, an empty array for
// a dynamic or associative array, and for an unpacked structure each member's
// own Table 7-1 value or, for a member with an initial value in its
// declaration, that value. An int branch with a real branch makes the result
// type real.
// Each pair is first selected with a known condition, so the target holds a
// branch value, and then with x or z. The dynamic arrays have two and three
// elements, so they are not combined element by element; the associative
// arrays have two elements each but are never combined that way. A tool that
// picked a branch or combined these elements would print a nonzero size.

class item_c;
  int v;
  function new(int v0);
    v = v0;
  endfunction
endclass

module test_conditional_ambiguous_nonintegral_default_values;
  typedef struct {
    int a = 9;
    logic [3:0] b;
    real c;
  } rec_t;
  typedef int dyn_t [];
  typedef int map_t [int];

  logic c1 = 1'b1;
  logic c0 = 1'b0;
  logic cx = 1'bx;
  logic cz = 1'bz;
  real r1 = 1.5, r2 = 2.5, rr;
  shortreal s1 = 0.5, s2 = 0.75, sr;
  int i3 = 3;
  string t1 = "ab", t2 = "cd", tr;
  item_c h1, h2, hr;
  rec_t p, q, pr;
  dyn_t d1, d2, dr;
  map_t m1, m2, mr;

  initial begin
    h1 = new(1);
    h2 = new(2);
    p = '{a: 1, b: 4'b0011, c: 1.0};
    q = '{a: 2, b: 4'b0011, c: 1.0};
    d1 = '{1, 2};
    d2 = '{1, 2, 3};
    m1[1] = 10;
    m1[2] = 20;
    m2[1] = 10;
    m2[2] = 21;

    rr = c1 ? r1 : r2;
    $write("real: %.2f", rr);
    rr = cx ? r1 : r2;
    $display(" %.2f", rr);
    sr = c0 ? s1 : s2;
    $write("shortreal: %.2f", sr);
    sr = cz ? s1 : s2;
    $display(" %.2f", sr);
    rr = c1 ? i3 : r1;
    $write("int and real: %.2f", rr);
    rr = cx ? i3 : r1;
    $display(" %.2f", rr);
    tr = c0 ? t1 : t2;
    $write("string: \"%s\"", tr);
    tr = cx ? t1 : t2;
    $display(" \"%s\" len=%0d", tr, tr.len());
    hr = c1 ? h1 : h2;
    $write("class: v=%0d", hr.v);
    hr = cx ? h1 : h2;
    $display(" null=%0d", hr == null);
    pr = c0 ? p : q;
    $write("struct: a=%0d b=%b c=%.2f", pr.a, pr.b, pr.c);
    pr = cx ? p : q;
    $display(" a=%0d b=%b c=%.2f", pr.a, pr.b, pr.c);
    dr = c1 ? d1 : d2;
    $write("dynamic: size=%0d", dr.size());
    dr = cx ? d1 : d2;
    $display(" size=%0d", dr.size());
    mr = c0 ? m1 : m2;
    $write("associative: num=%0d", mr.num());
    mr = cx ? m1 : m2;
    $display(" num=%0d", mr.num());
  end
endmodule
