/*
:name: test_casex_first_wildcard_item
:description: Casex treats unknown and high impedance bits in both the selector and case items as wildcards (IEEE 1800-2023 Section 12.5.2)
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.2
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_casex_first_wildcard_item.expected
*/
// IEEE 1800-2023 12.5.2: When several wildcard items match, only the first
// executes; a default executes only if no pattern matches.
// Oracle checks: The 5.052 release is a two-state engine and is not used as the
// oracle here.

module test_casex_first_wildcard_item;
  logic [3:0] selector;
  int chosen;
  task automatic choose();
    casex(selector)
      4'b10xx: chosen = 1;
      4'b1zzz: chosen = 2;
      default: chosen = 3;
    endcase
  endtask
  initial begin
    selector = 4'b1x01; choose(); $display("ambiguous=%0d", chosen);
    selector = 4'b0000; choose(); $display("default=%0d", chosen);
  end
endmodule
