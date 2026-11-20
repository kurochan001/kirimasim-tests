/*
:name: test_pla_plane_unknown_personality_control_values
:description: An x personality entry contributes an unknown literal in each PLA plane logic, including when another input controls the result and when z omits the other input (IEEE 1800-2023 Section 20.16.4)
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.16.4 20.16.1 20.16.2 20.16.3
:oracle: spec
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_pla_plane_unknown_personality_control_values.expected
*/
// In the plane format, an x personality bit takes the worst case of an
// input, whereas z omits that input (20.16.4). The three rows select
// (x,b), (a,x), and (x,don't-care). Thus the AND results are (x&b,a&x,x)
// and the OR results are (x|b,a|x,x). NAND and NOR invert those results
// (20.16.2). All four values of a,b distinguish x from either a constant,
// a true/complemented input, or an omitted input. Controlling 0 and 1 mask
// x in AND and OR respectively; the third row has no controlling input.
// Ascending indices follow 20.16.3. Each synchronous task updates its
// variable output at the call, without delay (20.16.1).

module test_pla_plane_unknown_personality_control_values;
  logic [1:2] personality [1:3];
  logic [1:2] inputs;
  logic [1:3] and_result, or_result, nand_result, nor_result;

  task automatic evaluate;
    $sync$and$plane(personality, inputs, and_result);
    $sync$or$plane(personality, inputs, or_result);
    $sync$nand$plane(personality, inputs, nand_result);
    $sync$nor$plane(personality, inputs, nor_result);
    $display("input=%b and=%b or=%b nand=%b nor=%b", inputs,
             and_result, or_result, nand_result, nor_result);
  endtask

  initial begin
    personality[1] = 2'bx1;
    personality[2] = 2'b1x;
    personality[3] = 2'bxz;
    inputs = 2'b00; evaluate;
    inputs = 2'b01; evaluate;
    inputs = 2'b10; evaluate;
    inputs = 2'b11; evaluate;
  end
endmodule
