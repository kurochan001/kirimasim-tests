/*
:name: test_sequence_local_formal_copies_and_casts
:description: a local output formal is cast and copied to its actual at the end of each matching thread, every attempt has its own copies of local input formals, which are cast from the actual and initialized before the declared local variables, local and the direction and type carry on to the next formals that give only a name, and an untyped formal lets a sequence assign a local variable of its caller (IEEE 1800-2023 Section 16.8.2)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.8.2 16.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_local_formal_copies_and_casts.expected
*/
// IEEE 1800-2023 §16.8.2: a local formal is a local variable of the named
// sequence (§16.10), and each attempt of an instance gets new copies. An
// input or inout local formal starts with the value of its actual, cast to
// the formal's type, and these initializations come before those of the
// local variables declared in the sequence, which may use them. At the end
// of each match the value of an inout or output local formal is cast to the
// type of its actual, a local variable of the caller; each matching thread
// goes on with its own copy. A port item with only a name takes local, the
// direction and the type of the item before it while no item in between
// gives local or a type. A caller's local variable passed whole to an untyped
// formal can be assigned in the sequence and read after it.
// Tick k is at 10 * k + 5. pick: go at tick 1, en at 2 and 3, data 18 then
// 37; the two matches of en[*1:2] end at 2 and 3 and give 18 and 37 to the
// 4-bit x, so 2 and 5. keep: st at ticks 5 and 6 with data 18 and 37; each
// attempt keeps v = 2 or 5 and w = v + 100. either: v is assigned in both
// operands of or, so it flows out of each thread (1 at tick 8, 2 at tick 9).
// inh: u takes local inout int from t, so u = 1 + 20 = 21 > 15 and q gets
// 21 cast to 4 bits; flag has its own type and is not local. untyped: put
// assigns data (40) to the caller's v. The calls record time:value of the
// caller's local variables one tick after the match; the lists are printed
// at the end.

`timescale 1ns/1ns

module test_sequence_local_formal_copies_and_casts;
  logic clk = 0, go = 0, en = 0, st = 0, g1 = 0, g2 = 0, st2 = 0, fl = 0, st3 = 0;
  int data = 0;
  string m[string];
  string order[] = '{"pick", "keep", "either", "inherit", "untyped"};

  function automatic void add(string name, string s);
    if (m.exists(name)) m[name] = {m[name], s};
    else m[name] = s;
  endfunction

  function automatic void rec1(string name, int v);
    add(name, $sformatf(" %0t:%0d", $time, v));
  endfunction

  function automatic void rec2(string name, int v, int w);
    add(name, $sformatf(" %0t:%0d/%0d", $time, v, w));
  endfunction

  function automatic string ends(string name);
    return m.exists(name) ? m[name] : "";
  endfunction

  always #5 clk = ~clk;   // tick k at 10 * k + 5

  sequence pick(local output int v);
    go ##1 (en[*1:2], v = data);
  endsequence

  sequence use_pick;
    logic [3:0] x;
    pick(x) ##1 (1'b1, rec1("pick", x));
  endsequence

  sequence keep(local input logic [3:0] v);
    int w = v + 100;
    ##2 (1'b1, rec2("keep", v, w));
  endsequence

  sequence either(local output int v);
    (g1, v = 1) or (g2 ##1 1'b1, v = 2);
  endsequence

  sequence use_either;
    int y;
    either(y) ##1 (1'b1, rec1("either", y));
  endsequence

  sequence inh(local inout int t, u, logic flag);
    (1'b1, t += 20, u += 20) ##0 (u > 15 && flag);
  endsequence

  sequence use_inh;
    logic [3:0] p, q;
    (st2, p = 1, q = 1) ##0 inh(p, q, fl) ##1 (1'b1, rec2("inherit", p, q));
  endsequence

  sequence put(lv);
    (1'b1, lv = data) ##1 (data == lv + 1);
  endsequence

  sequence use_put;
    int v;
    st3 ##0 put(v) ##1 (1'b1, rec1("untyped", v));
  endsequence

  c_pick: cover sequence (@(posedge clk) use_pick);
  c_keep: cover sequence (@(posedge clk) st ##0 keep(data));
  c_either: cover sequence (@(posedge clk) use_either);
  c_inh: cover sequence (@(posedge clk) use_inh);
  c_put: cover sequence (@(posedge clk) use_put);

  initial begin
    #10 go = 1;              // tick 1
    #10 go = 0; en = 1; data = 18;   // tick 2
    #10 data = 37;           // tick 3
    #10 en = 0; data = 0;    // tick 4
    #10 st = 1; data = 18;   // tick 5
    #10 data = 37;           // tick 6
    #10 st = 0; data = 0;    // tick 7
    #10 g1 = 1; g2 = 1;      // tick 8
    #10 g1 = 0; g2 = 0;      // tick 9
    #10 st2 = 1; fl = 1;     // tick 10
    #10 st2 = 0; fl = 0;     // tick 11
    #10 st3 = 1; data = 40;  // tick 12
    #10 st3 = 0; data = 41;  // tick 13
    #10 data = 0;            // tick 14
    #20;
    foreach (order[i]) $display("%s: [%s ]", order[i], ends(order[i]));
    $finish;
  end
endmodule
