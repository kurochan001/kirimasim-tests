/*
:name: test_vpi_force_and_release_concatenated_net_selections_and_variable
:description: VPI force and release treat a concatenation of net selections and a whole variable like the procedural statements
:tags: ch38
:type: simulation
:lrm: 1800-2023 38.34 10.6.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @vpi_force_release_target.c
:expected_stdout: @test_vpi_force_and_release_concatenated_net_selections_and_variable.expected
*/
module test_vpi_force_and_release_concatenated_net_selections_and_variable;
  bit [3:0] drive_left = 0, drive_right = 1;
  wire [3:0] left_vpi = drive_left, right_vpi = drive_right;
  wire [3:0] left_sv = drive_left, right_sv = drive_right;
  logic [7:0] value_vpi = 8'h52, value_sv = 8'h52;

  task automatic sample(input string phase_name);
    $display("%s: vpi=%h %h %h sv=%h %h %h", phase_name,
             left_vpi, right_vpi, value_vpi, left_sv, right_sv, value_sv);
  endtask

  initial begin
    #1;
    sample("initial");
    $vt_force_target({left_vpi[1], right_vpi[3:2], value_vpi});
    force {left_sv[1], right_sv[3:2], value_sv} = 11'h6a5;
    #1;
    sample("forced");
    drive_left = 9;
    drive_right = 5;
    value_vpi = 8'h68;
    value_sv = 8'h68;
    #1;
    sample("drivers updated");
    $vt_release_target({left_vpi[1], right_vpi[3:2], value_vpi});
    release {left_sv[1], right_sv[3:2], value_sv};
    sample("released");
    value_vpi = 8'h66;
    value_sv = 8'h66;
    #1;
    sample("procedural write");
  end
endmodule
