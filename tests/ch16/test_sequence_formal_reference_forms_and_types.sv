/*
:name: test_sequence_formal_reference_forms_and_types
:description: a sequence formal can stand for an identifier, an expression, a sequence, an event expression and the $ bound of a range; an untyped actual is put in parentheses and cast to its self-determined type unless it is a variable or $, a type also applies to the formals after it until untyped, a formal without a type has no default type, and a formal follows its actual at every tick instead of being passed by value (IEEE 1800-2023 Sections 16.8, 16.8.1)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.8 16.8.1
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_formal_reference_forms_and_types.expected
*/
// IEEE 1800-2023 §16.8: a reference to a formal can take the place of an
// identifier, an expression, a sequence, an event expression or the $ upper
// bound of a delay range. An actual for an untyped formal is put in
// parentheses and cast to its self-determined type before it replaces the
// formal, except when it is $ or a variable. A type in the port list applies
// to the following formals until the next type; a formal without one is
// untyped, as there is no default type. §16.8.1: the keyword untyped makes a
// formal after a typed one untyped again; an actual for a typed formal is
// cast to that type. A formal is not passed by value: each use reads the
// actual at that tick, and a local variable can keep the value of one tick.
// Tick k is at 10 * k + 5. At tick 1 a = b = 1 and w = 4'b0110; at tick 2
// c = 1 and w = 4'b1001; d is high at tick 5 and r around the falling edge
// at 20. So the one-bit a + b is 0 untyped but 2 as logic [1:0]; !a | b in
// parentheses is ANDed with c only at tick 2; w[1] is 1 then 0; w passed to
// bit [1:0] formals reads 2'b10 at tick 1 and 2'b01 at tick 2. Each cover
// adds the times of its matches to its list; the lists are printed at the
// end.
// Icarus Verilog 13.0 does not support these assertions. Verilator 5.052
// treats an untyped formal as one bit (untyped w, untyped after type), does
// not pass the type to q in s_inh, and rejects w[1] on a formal, sequence
// and event actuals, a formal as a range bound and local variables.

`timescale 1ns/1ns

module test_sequence_formal_reference_forms_and_types;
  logic clk = 0, a = 0, b = 0, c = 0, d = 0, r = 0;
  logic [3:0] w = 0;
  string m[string];
  string order[] = '{"untyped a + b", "logic [1:0] a + b", "untyped w", "parentheses",
                      "identifier", "sequence", "event", "$ bound", "bound 3", "inherited type",
                      "untyped after type", "follows actual", "local copy"};

  function automatic void hit(string name);
    string t = $sformatf(" %0t", $time);
    if (m.exists(name)) m[name] = {m[name], t};
    else m[name] = t;
  endfunction

  function automatic string ends(string name);
    return m.exists(name) ? m[name] : "";
  endfunction

  always #5 clk = ~clk;   // tick k at 10 * k + 5

  sequence s_two(x);
    x == 2'd2;
  endsequence

  sequence s_two_t(logic [1:0] x);
    x == 2'd2;
  endsequence

  sequence s_whole(x);
    x == 4'b0110;
  endsequence

  sequence s_and_c(x);
    x & c;
  endsequence

  sequence s_bit(x);
    x[1] ##1 !x[1];
  endsequence

  sequence s_then(q, y);
    q ##1 y;
  endsequence

  sequence s_on(ev, y);
    @(ev) y;
  endsequence

  sequence s_upto(x, hi);
    a ##[1:hi] x;
  endsequence

  sequence s_inh(bit [1:0] p, q);
    p == 2'b10 && q == 2'b10;
  endsequence

  sequence s_back(bit [1:0] p, untyped z);
    p == 2'b10 && z == 4'b0110;
  endsequence

  sequence s_track(bit [1:0] x);
    x == 2'b10 ##1 x == 2'b01;
  endsequence

  sequence s_hold(bit [1:0] x);
    bit [1:0] h;
    (1'b1, h = x) ##1 (h == 2'b10 && x == 2'b01);
  endsequence

  c_two_u: cover sequence (@(posedge clk) s_two(a + b)) hit("untyped a + b");
  c_two_t: cover sequence (@(posedge clk) s_two_t(a + b)) hit("logic [1:0] a + b");
  c_whole: cover sequence (@(posedge clk) s_whole(w)) hit("untyped w");
  c_par: cover sequence (@(posedge clk) s_and_c(!a | b)) hit("parentheses");
  c_bit: cover sequence (@(posedge clk) s_bit(w)) hit("identifier");
  c_seqf: cover sequence (@(posedge clk) s_then(a ##1 c, !c)) hit("sequence");
  c_ev: cover sequence (s_on(negedge clk, r)) hit("event");
  c_dollar: cover sequence (@(posedge clk) s_upto(d, $)) hit("$ bound");
  c_bound: cover sequence (@(posedge clk) s_upto(d, 3)) hit("bound 3");
  c_inh: cover sequence (@(posedge clk) s_inh(w, w)) hit("inherited type");
  c_back: cover sequence (@(posedge clk) s_back(w, w)) hit("untyped after type");
  c_track: cover sequence (@(posedge clk) s_track(w)) hit("follows actual");
  c_hold: cover sequence (@(posedge clk) s_hold(w)) hit("local copy");

  // Sets the values sampled at the next tick.
  task automatic tick(logic va, logic vb, logic vc, logic vd, logic [3:0] vw);
    a = va;
    b = vb;
    c = vc;
    d = vd;
    w = vw;
    #10;
  endtask

  initial begin
    #17 r = 1;   // high at the falling edge at 20 only
    #6 r = 0;
  end

  initial begin
    tick(0, 0, 0, 0, 4'b0000);   // tick 0
    tick(1, 1, 0, 0, 4'b0110);   // tick 1
    tick(0, 0, 1, 0, 4'b1001);   // tick 2
    tick(0, 0, 0, 0, 4'b0000);   // tick 3
    tick(0, 0, 0, 0, 4'b0000);   // tick 4
    tick(0, 0, 0, 1, 4'b0000);   // tick 5
    tick(0, 0, 0, 0, 4'b0000);   // tick 6
    tick(0, 0, 0, 0, 4'b0000);   // tick 7
    foreach (order[i]) $display("%s: [%s ]", order[i], ends(order[i]));
    $finish;
  end
endmodule
