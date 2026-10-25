/*
:name: test_property_if_case_forms
:description: A property if-else picks the property expression of the branch its condition chooses, and a property case picks the first item with a matching expression, a list of expressions or the default with or without its colon (IEEE 1800-2023 Sections 16.12.6 and 16.12.16)
:tags: ch16
:type: simulation
:lrm: 1800-2023 16.12.6 16.12.16 16.14.1 A.2.10
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_property_if_case_forms.expected
*/
// IEEE 1800-2023 §16.12.6: if (expr) p1 else p2 evaluates p1 when expr is
// true and p2 otherwise. §16.12.16: case (expr) compares expr with the items
// in order, takes the first match, and otherwise the default, which may be
// written with or without a colon; without a default and without a match the
// case property is vacuously true.
//
// The three properties below check sel and v at the tick where start is high.
// p_if needs v when sel is not zero and !v when it is zero; p_case needs v for
// sel 0 or 1, !v for 2 and v for its default (3); p_case2 needs v for 3 and
// !v for every other value through a default without a colon. Each phase
// holds sel and v for five ticks, and the fail actions count the failures
// (§16.14.1).

`timescale 1ns/1ns

module test_property_if_case_forms;
  logic clk = 0, start = 0, v = 0;
  int sel = 0;
  int f_if = 0, f_case = 0, f_case2 = 0;

  always #5 clk = ~clk;   // ticks at 5, 15, 25, ...

  property p_if;
    if (sel) v else !v;
  endproperty

  property p_case;
    case (sel)
      0, 1: v;
      2: !v;
      default: v;
    endcase
  endproperty

  property p_case2;
    case (sel)
      3: v;
      default !v;
    endcase
  endproperty

  a_if: assert property (@(posedge clk) start |-> p_if) else f_if++;
  a_case: assert property (@(posedge clk) start |-> p_case) else f_case++;
  a_case2: assert property (@(posedge clk) start |-> p_case2) else f_case2++;

  task automatic phase(int s, bit value);
    sel = s;
    v = value;
    for (int i = 0; i < 5; i++) begin
      start = (i == 0);
      #10;
    end
    $display("sel %0d, v %0d: if %0d, case %0d, default without colon %0d", s, value,
             f_if, f_case, f_case2);
    f_if = 0;
    f_case = 0;
    f_case2 = 0;
  endtask

  initial begin
    phase(0, 0);
    phase(0, 1);
    phase(2, 0);
    phase(2, 1);
    phase(3, 1);
    $finish;
  end
endmodule
