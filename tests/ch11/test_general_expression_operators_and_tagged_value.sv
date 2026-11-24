/*
:name: test_general_expression_operators_and_tagged_value
:description: An expression can contain operator attributes, nested assignments, membership tests and a context-typed tagged value
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.11 11.3.6 11.4.11 11.4.13 11.9
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_general_expression_operators_and_tagged_value.expected
*/
module test_general_expression_operators_and_tagged_value;
  typedef union tagged packed {
    void Idle;
    logic [3:0] Data;
  } message_t;
  message_t message;
  int sign_value, index_value = 4, total = 7, previous, assigned, arithmetic, chosen;
  bit included;

  initial begin
    sign_value = - (* grammar_unary *) 3;
    previous = index_value (* grammar_post *) ++;
    assigned = (total += 2);
    arithmetic = (assigned - (* grammar_binary *) index_value) * 2;
    chosen = sign_value < 0 ? (* grammar_conditional *) arithmetic : 0;
    included = chosen inside {8, [10:14]};
    message = tagged Data 4'(chosen);
    $display("previous=%0d index=%0d total=%0d chosen=%0d inside=%b",
             previous, index_value, total, chosen, included);
    case (message) matches
      tagged Data .payload: $display("tag payload=%h", payload);
      default: $display("unexpected tag");
    endcase
    $finish(0);
  end
endmodule
