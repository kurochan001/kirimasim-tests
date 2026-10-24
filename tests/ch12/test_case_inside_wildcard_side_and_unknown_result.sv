/*
:name: test_case_inside_wildcard_side_and_unknown_result
:description: case inside matches an item only when the inside operation with the case expression on the left yields 1 (IEEE 1800-2023 Section 12.5.4)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.4 11.4.13 11.4.6
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_case_inside_wildcard_side_and_unknown_result.expected
*/
// IEEE 1800-2023 §12.5.4: a case-inside statement compares the case expression
// with each item by the inside operator (11.4.13), the case expression being
// the left operand and the item the right operand. inside uses wildcard
// equality (11.4.6) for integral values: an x or z bit of the item is a
// do-not-care, an x or z bit of the case expression is not, and a comparison
// that depends on it yields x. An item is selected only when the operation
// yields 1; 0 and x are no match, the search goes on with the next item, and
// the default item runs when no item matches.
// wild() shows the do-not-care bits of the items (?, which is z, and x).
// side() has a known item and puts z or x into the case expression: if the
// case expression were the right operand, these bits would be do-not-cares and
// M would be chosen. after_x() shows that an item whose result is x is skipped
// in favour of a later item that yields 1 (Q), and that the default item runs
// when every item yields 0 or x (R).
// Icarus Verilog 13.0 does not support case inside, and Verilator 5.052,
// a two-state simulator, does not support the z arguments.

module test_case_inside_wildcard_side_and_unknown_result;
  function automatic string wild(logic [2:0] e);
    case (e) inside
      3'b0?1:  return "A";
      3'b1x0:  return "C";
      default: return "D";
    endcase
  endfunction

  function automatic string side(logic [2:0] e);
    case (e) inside
      3'b010:  return "M";
      default: return "N";
    endcase
  endfunction

  function automatic string after_x(logic [2:0] e);
    case (e) inside
      3'b000:  return "P";
      3'b00?:  return "Q";
      default: return "R";
    endcase
  endfunction

  initial begin
    $display("wild 011 %s", wild(3'b011));
    $display("wild 001 %s", wild(3'b001));
    $display("wild 110 %s", wild(3'b110));
    $display("wild 100 %s", wild(3'b100));
    $display("wild 111 %s", wild(3'b111));
    $display("side 010 %s", side(3'b010));
    $display("side 0z0 %s", side(3'b0z0));
    $display("side 0x0 %s", side(3'b0x0));
    $display("side z10 %s", side(3'bz10));
    $display("after_x 000 %s", after_x(3'b000));
    $display("after_x 00x %s", after_x(3'b00x));
    $display("after_x 00z %s", after_x(3'b00z));
    $display("after_x 001 %s", after_x(3'b001));
    $display("after_x 01x %s", after_x(3'b01x));
    $display("after_x 0x0 %s", after_x(3'b0x0));
  end
endmodule
