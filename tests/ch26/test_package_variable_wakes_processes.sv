/*
:name: test_package_variable_wakes_processes
:description: A change of a package variable wakes event controls, always_comb, continuous assignments and wait statements that read it (IEEE 1800-2023 Section 26.3)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.3 9.4.2 9.2.2.2 10.3.2 9.4.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_package_variable_wakes_processes.expected
*/
// IEEE 1800-2023 §26.3: a variable declared in a package is one variable,
// read and written through pk::v from any module. Its changes wake the
// processes sensitive to it as for any other variable: an event control
// @(pk::v) (9.4.2), an always_comb that reads it (9.2.2.2), a continuous
// assignment (10.3.2) and a wait statement (9.4.3).

package pk;
  logic [7:0] v = 8'h01;
endpackage

module test_package_variable_wakes_processes;
  logic [7:0] comb_copy, assign_copy;
  int events = 0;

  always @(pk::v) events++;
  always_comb comb_copy = pk::v;
  assign assign_copy = pk::v;

  initial begin
    wait (pk::v == 8'ha5);
    $display("t=%0d wait (pk::v == 8'ha5) resumes", $time);
  end

  initial begin
    #5 pk::v = 8'h00;
    #5 pk::v = 8'ha5;
    #5 pk::v = 8'ha5;
    #5 $display("t=%0d events=%0d comb_copy=%h assign_copy=%h", $time, events, comb_copy,
                assign_copy);
  end
endmodule
