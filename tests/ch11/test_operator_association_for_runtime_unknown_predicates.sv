/*
:name: test_operator_association_for_runtime_unknown_predicates
:description: Mixed implication and equivalence and nested conditionals group from the right while mixed equality operators group from the left
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.3.2 11.4.5 11.4.7 11.4.11
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_operator_association_for_runtime_unknown_predicates.expected
*/
module test_operator_association_for_runtime_unknown_predicates;
  logic a, b, c, unknown_cond, false_cond;
  logic [3:0] first_value, second_value, final_value;
  logic [3:0] equality_x, equality_y, equality_z;

  initial begin
    #1;
    a = 1'b0;
    b = 1'b1;
    c = 1'bx;
    unknown_cond = 1'bx;
    false_cond = 1'b0;
    first_value = 4'b1000;
    second_value = 4'b1110;
    final_value = 4'b1010;
    equality_x = 4'b1011;
    equality_y = 4'b1x11;
    equality_z = 4'b0010;

    $display("implication then equivalence=%b/%b/%b", a -> b <-> c,
             a -> (b <-> c), (a -> b) <-> c);
    $display("equivalence then implication=%b/%b/%b", c <-> a -> b,
             c <-> (a -> b), (c <-> a) -> b);
    $display("conditional=%b/%b/%b",
             unknown_cond ? first_value : false_cond ? second_value : final_value,
             unknown_cond ? first_value : (false_cond ? second_value : final_value),
             (unknown_cond ? first_value : false_cond) ? second_value : final_value);
    $display("mixed equality=%b/%b/%b", equality_x ==? equality_y != equality_z,
             (equality_x ==? equality_y) != equality_z,
             equality_x ==? (equality_y != equality_z));
    $finish(0);
  end
endmodule
