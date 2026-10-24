/*
:name: test_array_invalid_index_read_aggregates
:description: reading an unpacked array whose elements are queues, dynamic or associative arrays, fixed-size arrays, unpacked structures or unpacked unions with an invalid index gives an empty array, an array of default elements, a structure of default members (or their initial assignments) and the default of the first union member (IEEE 1800-2023 Section 7.4.5)
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.4.5
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_array_invalid_index_read_aggregates.expected
*/
// IEEE 1800-2023 §7.4.5: reading an unpacked array with an invalid index (out
// of bounds, or with an x or z bit) returns the value of Table 7-1 for the
// element type. For a variable-size array element (queue, dynamic or
// associative array) it is an array with no elements; for a fixed-size array
// element, an array whose elements all have the value of the table for their
// type ('x for 4-state, '0 for 2-state); for an unpacked structure, each member
// gets the value of the table for its type unless the member has an initial
// assignment in its declaration, which it then gets; for an unpacked union,
// the value for the type of its first member.
// Every element is first filled with other values, shown by the reads of the
// valid index 0. Each array is then read with the out-of-bounds index 5 and
// with the index 2'bx0. The member c of st_t has the initial assignment 9 but
// is set to 7 in the elements, so only the rule for initial assignments gives
// 9. Icarus Verilog 13.0 does not support unpacked structures. Verilator 5.052
// returns the stored element for both invalid indices.

module test_array_invalid_index_read_aggregates;
  typedef struct {
    int a;
    logic [3:0] b;
    int c = 9;
    string s;
    real r;
  } st_t;

  typedef union {
    logic [7:0] l;
    int i;
  } un_t;

  int aq [0:1][$];
  int ad [0:1][];
  int aa [0:1][string];
  logic [3:0] fx [0:1][0:2];
  int fi [0:1][0:2];
  st_t sa [0:1];
  un_t ua [0:1];

  int tq[$];
  int td[];
  int ta[string];
  logic [3:0] tf [0:2];
  int ti [0:2];
  st_t ts;
  un_t tu;

  int oob = 5;
  logic [1:0] xi = 2'bx0;

  initial begin
    foreach (aq[k]) begin
      aq[k] = '{1, 2};
      ad[k] = '{3, 4, 5};
      aa[k]["key"] = 6;
      fx[k] = '{4'h1, 4'h2, 4'h3};
      fi[k] = '{7, 8, 9};
      sa[k] = '{a: 5, b: 4'h3, c: 7, s: "q", r: 1.5};
      ua[k].l = 8'h5a;
    end
    tq = aq[0]; td = ad[0]; ta = aa[0]; tf = fx[0]; ti = fi[0]; ts = sa[0]; tu = ua[0];
    $display("valid: q=%0d d=%0d a=%0d fx=%h,%h,%h fi=%0d,%0d,%0d", tq.size(), td.size(),
             ta.num(), tf[0], tf[1], tf[2], ti[0], ti[1], ti[2]);
    $display("valid: st a=%0d b=%h c=%0d s=\"%s\" r=%0.1f un l=%h", ts.a, ts.b, ts.c, ts.s,
             ts.r, tu.l);

    tq = aq[oob]; td = ad[oob]; ta = aa[oob]; tf = fx[oob]; ti = fi[oob]; ts = sa[oob];
    tu = ua[oob];
    $display("out of bounds: q=%0d d=%0d a=%0d fx=%h,%h,%h fi=%0d,%0d,%0d", tq.size(),
             td.size(), ta.num(), tf[0], tf[1], tf[2], ti[0], ti[1], ti[2]);
    $display("out of bounds: st a=%0d b=%h c=%0d s=\"%s\" r=%0.1f un l=%h", ts.a, ts.b, ts.c,
             ts.s, ts.r, tu.l);

    tq = aq[xi]; td = ad[xi]; ta = aa[xi]; tf = fx[xi]; ti = fi[xi]; ts = sa[xi]; tu = ua[xi];
    $display("x index: q=%0d d=%0d a=%0d fx=%h,%h,%h fi=%0d,%0d,%0d", tq.size(), td.size(),
             ta.num(), tf[0], tf[1], tf[2], ti[0], ti[1], ti[2]);
    $display("x index: st a=%0d b=%h c=%0d s=\"%s\" r=%0.1f un l=%h", ts.a, ts.b, ts.c, ts.s,
             ts.r, tu.l);
  end
endmodule
