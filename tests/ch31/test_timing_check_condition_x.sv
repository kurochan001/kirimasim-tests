/*
:name: test_timing_check_condition_x
:description: a timing check condition that uses case equality or inequality, inversion or no operator does not enable the check when the conditioning signal is x, while a condition with == or != does, and each enabled has its own notifier toggled (IEEE 1800-2023 Sections 31.7, 31.6 and 31.2)
:tags: ch31
:type: simulation
:lrm: 1800-2023 31.7 31.6 31.2
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_timing_check_condition_x.expected
*/
// IEEE 1800-2023 §31.7: a timing check event may be conditioned by &&& with a
// scalar net. The comparison in the condition is deterministic with ===, !==,
// ~ or no operator, or nondeterministic with == or !=. With a deterministic
// comparison, an x on the conditioning signal does not enable the check; with
// a nondeterministic one, x does enable it. §31.6: each check toggles its own
// notifier on a violation, from 0 to 1 and from 1 to 0. §31.2: the event is
// posedge clk with a timing_check_condition.
//
// Six checks share the event posedge clk and the data signal d, with setup 5
// ns and hold 1 ns, and differ only in the condition: en, ~en, en === 1,
// en !== 1, en == 1 and en != 0. The conditioning signal en is x at the first
// violation, 1 at the second and 0 at the third. Each violation is a data
// change 2 ns before the clock. The test prints the six notifiers after each
// violation.

`timescale 1ns/1ns

module condition_device(input logic clk, input logic d, input wire en,
                        output logic q);
  logic plain = 0, inverted = 0, case_equal = 0, case_not_equal = 0;
  logic equal = 0, not_equal = 0;

  specify
    specparam tSU = 5, tHLD = 1;
    $setuphold(posedge clk &&& en, d, tSU, tHLD, plain);
    $setuphold(posedge clk &&& (~en), d, tSU, tHLD, inverted);
    $setuphold(posedge clk &&& (en === 1'b1), d, tSU, tHLD, case_equal);
    $setuphold(posedge clk &&& (en !== 1'b1), d, tSU, tHLD, case_not_equal);
    $setuphold(posedge clk &&& (en == 1'b1), d, tSU, tHLD, equal);
    $setuphold(posedge clk &&& (en != 1'b0), d, tSU, tHLD, not_equal);
  endspecify

  assign q = d;
endmodule

module test_timing_check_condition_x;
  logic clk = 0, d = 0, en = 1'bx;
  wire q;

  condition_device u(.clk(clk), .d(d), .en(en), .q(q));

  task automatic show(input string when);
    $display("en=%s plain=%b inverted=%b case_equal=%b case_not_equal=%b equal=%b not_equal=%b",
             when, u.plain, u.inverted, u.case_equal, u.case_not_equal,
             u.equal, u.not_equal);
  endtask

  initial begin
    #8 d = 1;
    #2 clk = 1;
    #2 show("x");
    #8 clk = 0;
    en = 1;
    #8 d = 0;
    #2 clk = 1;
    #2 show("1");
    #8 clk = 0;
    en = 0;
    #8 d = 1;
    #2 clk = 1;
    #2 show("0");
  end
endmodule
