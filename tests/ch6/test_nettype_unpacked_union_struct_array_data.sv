/*
:name: test_nettype_unpacked_union_struct_array_data
:description: A user-defined nettype can have as its data type an unpacked union of real and logic members, an unpacked structure holding a fixed-size array of unpacked structures of shortreal and bit members, and a fixed-size array of such unions, and its resolver combines whole driver values of these types (IEEE 1800-2023 Section 6.6.7)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.6.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_nettype_unpacked_union_struct_array_data.expected
*/
// IEEE 1800-2023 §6.6.7: the data type of a user-defined nettype can be a
// fixed-size unpacked array, an unpacked structure or an unpacked union when
// each of its elements is again a valid data type for such a net: a 4-state
// or 2-state integral type, real or shortreal, or another such aggregate.
// The resolver of the nettype takes a dynamic array of the driver values and
// returns one value of the data type.
// Each net below has two continuous drivers:
// - ru_net is an unpacked union of a real and a logic [7:0]; its resolver
//   adds the real members, 1.25 + 2.5;
// - outer_net is an unpacked structure of a fixed-size array of two inner_t,
//   each an unpacked structure of a shortreal and a bit [3:0], and of a
//   logic [3:0] tag; its resolver adds the shortreal members and ORs the
//   bit and logic members, element by element;
// - pair_net is a fixed-size array of two ru_t unions; its resolver adds the
//   real members of each element.
// The drivers are variables set at time 0, and the nets are printed at time 1.
// Oracle checks: Icarus Verilog 13.0 does not support unpacked structures,
// and the 5.054 release of Verilator does not support a nettype with a
// resolver, so the expected output follows the cited clause alone.

module test_nettype_unpacked_union_struct_array_data;
  typedef union {real r; logic [7:0] code;} ru_t;
  typedef struct {shortreal s; bit [3:0] b;} inner_t;
  typedef struct {inner_t parts [2]; logic [3:0] tag;} outer_t;
  typedef ru_t ru_pair_t [2];

  function automatic ru_t add_ru(input ru_t d[]);
    ru_t t;
    t.r = 0.0;
    foreach (d[i]) t.r += d[i].r;
    return t;
  endfunction

  function automatic outer_t mix_outer(input outer_t d[]);
    outer_t t;
    for (int k = 0; k < 2; k++) begin
      t.parts[k].s = 0.0;
      t.parts[k].b = 4'b0000;
    end
    t.tag = 4'b0000;
    foreach (d[i]) begin
      for (int k = 0; k < 2; k++) begin
        t.parts[k].s += d[i].parts[k].s;
        t.parts[k].b |= d[i].parts[k].b;
      end
      t.tag |= d[i].tag;
    end
    return t;
  endfunction

  function automatic ru_pair_t add_pair(input ru_pair_t d[]);
    ru_pair_t t;
    foreach (t[k]) t[k].r = 0.0;
    foreach (d[i])
      foreach (t[k]) t[k].r += d[i][k].r;
    return t;
  endfunction

  nettype ru_t ru_net with add_ru;
  nettype outer_t outer_net with mix_outer;
  nettype ru_pair_t pair_net with add_pair;

  ru_net nu;
  outer_net no;
  pair_net np;
  ru_t du1, du2;
  outer_t do1, do2;
  ru_pair_t dp1, dp2;

  assign nu = du1;
  assign nu = du2;
  assign no = do1;
  assign no = do2;
  assign np = dp1;
  assign np = dp2;

  initial begin
    du1.r = 1.25;
    du2.r = 2.5;
    do1.parts[0].s = 0.5;
    do1.parts[0].b = 4'b0001;
    do1.parts[1].s = 1.0;
    do1.parts[1].b = 4'b0010;
    do1.tag = 4'b0100;
    do2.parts[0].s = 0.25;
    do2.parts[0].b = 4'b1000;
    do2.parts[1].s = 2.0;
    do2.parts[1].b = 4'b0100;
    do2.tag = 4'b0001;
    dp1[0].r = 0.5;
    dp1[1].r = 3.0;
    dp2[0].r = 0.25;
    dp2[1].r = 1.0;
    #1;
    $display("union: r=%0.2f", nu.r);
    $display("structure: parts[0] s=%0.2f b=%b, parts[1] s=%0.2f b=%b, tag=%b",
             no.parts[0].s, no.parts[0].b, no.parts[1].s, no.parts[1].b, no.tag);
    $display("array of unions: [0] r=%0.2f, [1] r=%0.2f", np[0].r, np[1].r);
  end
endmodule
