/*
:name: test_static_prefix_of_field_selects
:description: a field select is a static prefix when the part before its last dot is one, so always_comb reading a field through an identifier, a constant index or another such field is sensitive to that field only, and through a variable index to the whole array (IEEE 1800-2023 Section 11.5.3)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.5.3 9.2.2.2.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_static_prefix_of_field_selects.expected
*/
// IEEE 1800-2023 §11.5.3: an identifier is a static prefix, a field select is
// one if its field select prefix (the part before the last dot) is one, and
// an indexing select is one if its prefix is one and its index is a constant
// expression. Nothing else is a static prefix. §9.2.2.2.1: the implicit
// sensitivity of always_comb is the expansion of the longest static prefix
// of each select it reads.
// s.f and o.in.f have static prefixes (s, and o.in whose prefix o is static),
// and so does arr[1].f; each is its own longest static prefix, so the blocks
// that read them wake only for changes of that field. arr[i] has a variable
// index and is not static, so the field select arr[i].f is not static either:
// its longest static prefix is arr, and that block wakes for a change of any
// member of any element, and for i.
// Each block counts its runs with a task, whose contents add nothing to the
// sensitivity. After the runs at time 0, one member changes per time unit,
// and the counts and outputs are printed one unit later. A tool that took
// arr[i].f as static would not run the second block for arr[0].g and
// arr[1].g, and one that used whole variables would run the other blocks for
// s.g, arr[1].g, o.in.g and o.h.
// Icarus Verilog 13.0 does not support unpacked structures, and the 5.054
// release of Verilator stops with a settle region that does not converge.

module test_static_prefix_of_field_selects;
  typedef struct {
    logic [7:0] f;
    logic [7:0] g;
  } pair_t;
  typedef struct {
    pair_t in;
    logic [7:0] h;
  } outer_t;

  pair_t s = '{f: 8'd1, g: 8'd2};
  pair_t arr [0:1] = '{'{f: 8'd10, g: 8'd11}, '{f: 8'd20, g: 8'd21}};
  outer_t o = '{in: '{f: 8'd30, g: 8'd31}, h: 8'd32};
  int i = 0;
  int rs, rv, rc, rn;
  logic [7:0] ys, yv, yc, yn;

  task bump_s();
    rs++;
  endtask
  task bump_v();
    rv++;
  endtask
  task bump_c();
    rc++;
  endtask
  task bump_n();
    rn++;
  endtask

  always_comb begin
    bump_s();
    ys = s.f;
  end
  always_comb begin
    bump_v();
    yv = arr[i].f;
  end
  always_comb begin
    bump_c();
    yc = arr[1].f;
  end
  always_comb begin
    bump_n();
    yn = o.in.f;
  end

  task automatic show(string what);
    #1 $display("%s: runs %0d %0d %0d %0d  s.f=%0d arr[i].f=%0d arr[1].f=%0d o.in.f=%0d", what,
                rs, rv, rc, rn, ys, yv, yc, yn);
  endtask

  initial begin
    show("start");
    s.g = 8'd3;
    show("s.g");
    s.f = 8'd4;
    show("s.f");
    arr[0].g = 8'd12;
    show("arr[0].g");
    arr[1].g = 8'd22;
    show("arr[1].g");
    arr[1].f = 8'd23;
    show("arr[1].f");
    o.in.g = 8'd33;
    show("o.in.g");
    o.h = 8'd34;
    show("o.h");
    o.in.f = 8'd35;
    show("o.in.f");
    i = 1;
    show("i");
  end
endmodule
