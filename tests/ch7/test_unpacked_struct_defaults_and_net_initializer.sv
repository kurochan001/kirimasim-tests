/*
:name: test_unpacked_struct_defaults_and_net_initializer
:description: an unpacked structure keeps member initializers, an explicit initializer overrides them, and a net of the type ignores them
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.2.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_unpacked_struct_defaults_and_net_initializer.expected
*/
// IEEE 1800-2023 7.2: a structure is unpacked unless it is qualified packed,
// and an unpacked structure can have members of any data type and any number
// of typed declarators. 7.2.2: an explicit variable initializer suppresses the
// initial assignments written in the structure type, and a type member
// initializer is ignored when the type declares a net without a user-defined
// nettype. The test declares an unpacked structure with member initializers
// and a string member, overrides them with an assignment pattern, passes the
// structure to a task by value, and shows that a net of a similar type starts
// with z instead of its member initializers.

typedef struct {
  (* keep = "true" *) int a = 3;
  logic [3:0] b;
  int c, d;
  string s = "hi";
} cfg_t;

typedef struct {
  integer a = 3;
  logic [7:0] b = 8'h5A;
} netcfg_t;

module test_unpacked_struct_defaults_and_net_initializer;
  cfg_t c1;
  cfg_t c2 = '{a: 9, b: 4'h2, c: 0, d: 0, s: "ex"};
  cfg_t c3 = '{a: 1, b: 4'hF, c: 3, d: 4, s: "yo"};
  wire netcfg_t wn;

  function automatic cfg_t make(input int x);
    cfg_t t;
    t.a = x;
    return t;
  endfunction

  task automatic show(input cfg_t c);
    $display("task a=%0d b_unknown=%0d s=%s", c.a, $isunknown(c.b), c.s);
  endtask

  initial begin
    $display("c1 a=%0d b_unknown=%0d s=%s", c1.a, $isunknown(c1.b), c1.s);
    $display("c2 a=%0d b=%h s=%s", c2.a, c2.b, c2.s);
    $display("c3 a=%0d b=%h s=%s", c3.a, c3.b, c3.s);
    $display("net a_unknown=%0d b=%b", $isunknown(wn.a), wn.b);
    c3 = make(6);
    show(c3);
  end
endmodule
