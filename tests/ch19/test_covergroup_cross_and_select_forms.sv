/*
:name: test_covergroup_cross_and_select_forms
:description: A cross of two coverpoints keeps its automatic bins, and a cross with a label, an iff guard and a body of a function and select expressions of every form defines its own bins: binsof of a bin and of a coverpoint, intersect, negation, && and ||, parentheses, with and matches, a cross identifier and a cross set expression (IEEE 1800-2023 Sections 19.6 and 19.6.1)
:tags: ch19
:type: simulation
:lrm: 1800-2023 19.6 19.6.1 19.6.1.2 19.6.1.3 19.6.1.4 19.11.2 A.2.11 19.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_covergroup_cross_and_select_forms.expected
*/
// IEEE 1800-2023 §19.6 with A.2.11: a cross names two or more coverpoints
// or variables, may have an iff guard, and has a body that is a semicolon or
// braces around function declarations, options and bins selections. §19.6.1:
// a bins selection is a bins keyword, a name and a select expression, which
// may be binsof of a coverpoint bin or coverpoint, optionally with intersect
// and a range list, negated, combined with && and || or parentheses, filtered
// with with and matches, or a cross identifier or cross set expression.
//
// x1 crosses ca and cb without a body and keeps the 16 automatic bins of the
// four values each; the five sampled pairs cover five of them. x2 keeps no
// automatic bins, and all eleven of its selections cover one of the samples:
// both0, any1, not2, paren, withx, withm, withall, selx, setx, fnx and cond.
// The covergroup coverage is the average of the two crosses, so 31.25 and
// 100 give 82.8125 as the mean of the two coverpoints and two crosses. Icarus
// Verilog 13.0 has no covergroups, and the 5.052
// release of the other tool does not support a function in a cross body or a
// cross set expression, so the expected output follows the standard.

module test_covergroup_cross_and_select_forms;
  bit [1:0] a, b;
  bit en = 1;

  covergroup cg;
    ca: coverpoint a { bins v[] = {[0:3]}; }
    cb: coverpoint b { bins w[] = {[0:3]}; }
    x1: cross ca, cb;
    x2: cross ca, cb iff (en) {
      function automatic CrossQueueType diagonal();
        CrossQueueType q;
        CrossValType t;
        t.ca = 1;
        t.cb = 1;
        q.push_back(t);
        return q;
      endfunction
      option.cross_retain_auto_bins = 0;
      bins both0 = binsof(ca.v[0]) && binsof(cb.w[0]);
      bins any1 = binsof(ca.v[1]) || binsof(cb.w[1]);
      bins not2 = !binsof(ca) intersect {2};
      bins paren = (binsof(ca) intersect {[0:1]}) || (binsof(cb) intersect {3});
      bins withx = x1 with (ca == 0);
      bins withm = x1 with (ca == 0) matches 1;
      bins withall = x1 with (ca == 0) matches $;
      bins selx = x1;
      bins setx = '{ '{1, 1} };
      bins fnx = diagonal() matches 1;
      bins cond = binsof(ca) intersect {[0:1]} iff (en);
    }
  endgroup

  cg g = new;

  task automatic put(bit [1:0] va, bit [1:0] vb);
    a = va;
    b = vb;
    g.sample();
  endtask

  initial begin
    put(0, 0);
    put(1, 1);
    put(2, 2);
    put(3, 3);
    put(1, 3);
    $display("cross %0.3f", g.get_inst_coverage());
    $finish;
  end
endmodule
