/*
:name: test_syntax_case_statement_forms
:description: case, casez and casex with unique, unique0 and priority, several expressions in an item, default with or without a colon and a null statement item select the statements of A.6.7 and 12.5 (IEEE 1800-2023 Sections 12.5.1 to 12.5.3, A.6.7)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5 12.5.1 12.5.3 A.6.7 A.6.4
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_syntax_case_statement_forms.expected
*/
// IEEE 1800-2023 A.6.7: a case statement is a case, casez or casex keyword with
// an expression, items and endcase, optionally qualified by unique, unique0
// or priority; an item is a list of expressions or default with an optional
// colon before its statement; "case (e) matches" takes pattern items, and
// "case (e) inside" takes range lists. §12.5.1: casez treats z and ? as
// do-not-care bits and casex also treats x. §12.5.3: all three qualifiers act
// on the first match; unique0 allows no match. §12.5.4: inside uses set
// membership.
//
// plain shows a list of two expressions, a default without a colon, and a
// case without a default whose value matches nothing. casez_f and casex_f
// show the do-not-care bits. qual, qual0 and qualp show the three
// qualifiers.
//
// The expected output follows the standard; Icarus Verilog 13.0 does not
// support a case item expression with a do-not-care "?" in every position.

module test_syntax_case_statement_forms;
  function automatic int plain(input int x);
    case (x)
      0: return 10;
      1, 2: return 20;
      default return 30;
    endcase
  endfunction

  function automatic int plain_no_default(input int x);
    case (x)
      0: return 1;
    endcase
    return 2;
  endfunction

  function automatic int casez_f(input logic [3:0] x);
    casez (x)
      4'b1???: return 1;
      4'b01??: return 2;
      default: return 3;
    endcase
  endfunction

  function automatic int casex_f(input logic [3:0] x);
    casex (x)
      4'b1xxx: return 1;
      default: return 2;
    endcase
  endfunction

  function automatic int qual(input int x);
    unique case (x)
      0: return 1;
      1: return 2;
    endcase
    return 3;
  endfunction

  function automatic int qual0(input int x);
    unique0 case (x)
      0: return 1;
    endcase
    return 2;
  endfunction

  function automatic int qualp(input int x);
    priority casez (x)
      1: return 1;
      default: return 2;
    endcase
  endfunction

  initial begin
    int r = 0;

    $display("plain: %0d %0d %0d", plain(0), plain(2), plain(5));
    $display("no default: %0d %0d", plain_no_default(0), plain_no_default(1));
    $display("casez: %0d %0d %0d", casez_f(4'b1zzz), casez_f(4'b0100), casez_f(4'b0010));
    $display("casex: %0d %0d", casex_f(4'b1010), casex_f(4'b1x01));
    $display("qualifiers: %0d %0d %0d", qual(0), qual0(5), qualp(1));
    case (2)
      2: ;
      default: r = 5;
    endcase
    case (3)
      1: r = 1;
      default: r = 9;
    endcase
    $display("null and default: r=%0d", r);
  end
endmodule
