/*
:name: test_sequence_default_actuals_and_name_scopes
:description: names in the body and in the default actuals of a named sequence are resolved where the sequence is declared, while the actuals of an instance are resolved where the instance is; defaults, including a sequence and a delay, are used for omitted actuals and overridden by actuals bound by position or by name, and an actual can use a local variable of the instantiating sequence (IEEE 1800-2023 Section 16.8)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_sequence_default_actuals_and_name_scopes.expected
*/
// IEEE 1800-2023 §16.8: a formal can have a default actual, which is used
// when the instance gives no actual for it; an untyped default can be of any
// kind, here a sequence and a delay count. Actuals override the defaults and
// are bound by position or by name. Names in the body and in the defaults
// are resolved from the scope of the declaration, names in the actuals from
// the scope of the instance, and an actual can refer to a local variable in
// scope at the instance.
// The sequences of block g use the en and d of g; the module has its own en
// and d. Tick k is at 10 * k + 5: g.en is high at tick 1, g.d at 2 and 4,
// the module's en at 3 and d at 6, b at 2, 4 and 6; data is 7 at tick 3 and
// 8 at tick 4. s_res with its default x (g.en) matches at tick 2; with the
// module's en as actual at tick 4. s_tail by default is (g.en ##1 g.d) ##2 b
// and ends at tick 4; with n = 4 it ends at tick 6. s_loc keeps data in v
// at tick 3 and passes v + 1 to s_eq, which holds at tick 4. Each cover adds
// the times of its matches to its list; the lists are printed at the end.
// Icarus Verilog 13.0 does not support these assertions; Verilator 5.052
// does not support default actuals and local variables (with the actuals
// written out, by position and by name agree with the standard).

`timescale 1ns/1ns

module test_sequence_default_actuals_and_name_scopes;
  logic clk = 0, en = 0, d = 0, b = 0;
  int data = 0;
  string m[string];
  string order[] = '{"default x", "by position", "by name", "all defaults", "n by name",
                      "local in actual"};

  function automatic void hit(string name);
    string t = $sformatf(" %0t", $time);
    if (m.exists(name)) m[name] = {m[name], t};
    else m[name] = t;
  endfunction

  function automatic string ends(string name);
    return m.exists(name) ? m[name] : "";
  endfunction

  always #5 clk = ~clk;   // tick k at 10 * k + 5

  if (1) begin : g
    logic en = 0, d = 0;

    sequence s_res(x = en, y);
      x ##1 (y && d);
    endsequence

    sequence s_tail(q = en ##1 d, n = 2);
      q ##n b;
    endsequence
  end

  sequence s_eq(x, y);
    x == y;
  endsequence

  sequence s_loc;
    int v;
    (en, v = data) ##1 s_eq(data, v + 1);
  endsequence

  c_def: cover sequence (@(posedge clk) g.s_res(.y(b))) hit("default x");
  c_pos: cover sequence (@(posedge clk) g.s_res(en, b)) hit("by position");
  c_name: cover sequence (@(posedge clk) g.s_res(.y(b), .x(en))) hit("by name");
  c_tail: cover sequence (@(posedge clk) g.s_tail) hit("all defaults");
  c_tail4: cover sequence (@(posedge clk) g.s_tail(.n(4))) hit("n by name");
  c_loc: cover sequence (@(posedge clk) s_loc) hit("local in actual");

  // Sets the values sampled at the next tick.
  task automatic tick(logic v_gen, logic v_gd, logic v_en, logic v_d, logic v_b, int v_data);
    g.en = v_gen;
    g.d = v_gd;
    en = v_en;
    d = v_d;
    b = v_b;
    data = v_data;
    #10;
  endtask

  initial begin
    tick(0, 0, 0, 0, 0, 0);   // tick 0
    tick(1, 0, 0, 0, 0, 0);   // tick 1
    tick(0, 1, 0, 0, 1, 0);   // tick 2
    tick(0, 0, 1, 0, 0, 7);   // tick 3
    tick(0, 1, 0, 0, 1, 8);   // tick 4
    tick(0, 0, 0, 0, 0, 0);   // tick 5
    tick(0, 0, 0, 1, 1, 0);   // tick 6
    tick(0, 0, 0, 0, 0, 0);   // tick 7
    foreach (order[i]) $display("%s: [%s ]", order[i], ends(order[i]));
    $finish;
  end
endmodule
