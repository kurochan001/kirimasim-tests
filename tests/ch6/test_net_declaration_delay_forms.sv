/*
:name: test_net_declaration_delay_forms
:description: A net declaration can give its assignment one delay value or a parenthesized list of one, two or three delays, each of which can be min:typ:max; one value applies to every transition, two give the rise and fall delays and the smaller for z, three give rise, fall and turn-off (IEEE 1800-2023 Section 6.7)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.7 10.3.3 28.16
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_net_declaration_delay_forms.expected
*/
// IEEE 1800-2023 §6.7: the delay of a net declaration (delay3) is # followed
// by one delay value, or by a parenthesized list of one to three
// min:typ:max expressions. For a scalar net with a continuous assignment the
// delays work as gate delays (10.3.3, 28.16): one value is used for every
// change, two are the rise and the fall delay with the smaller one for a
// change to z, and three are the rise, fall and turn-off delays.
// s goes to 1 at 20, to 0 at 40 and to z at 60. d_one (#6) follows after 6;
// d_two (#(2, 8)) rises after 2, falls after 8 and turns off after 2; d_three
// (#(2, 8, 12)) rises after 2, falls after 8 and turns off after 12; d_mtm
// (#(4:4:4), all three values the same) changes after 4. The values are shown
// at times between the changes.

`timescale 1ns/1ns
module test_net_declaration_delay_forms;
  logic s = 1'b0;
  wire #6 d_one = s;
  wire #(2, 8) d_two = s;
  wire #(2, 8, 12) d_three = s;
  wire #(4:4:4) d_mtm = s;

  task automatic show();
    $display("t=%0d one=%b two=%b three=%b mtm=%b", $time, d_one, d_two, d_three, d_mtm);
  endtask

  initial begin
    #20 s = 1'b1;
    #3 show();   // 23
    #2 show();   // 25
    #2 show();   // 27
    #13 s = 1'b0;
    #5 show();   // 45
    #2 show();   // 47
    #2 show();   // 49
    #11 s = 1'bz;
    #3 show();   // 63
    #2 show();   // 65
    #2 show();   // 67
    #6 show();   // 73
  end
endmodule
