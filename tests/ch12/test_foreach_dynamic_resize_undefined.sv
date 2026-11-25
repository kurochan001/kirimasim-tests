/*
:name: test_foreach_dynamic_resize_undefined
:description: Observe indices after resizing a dynamic array during foreach and check a stable control
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.7.3
:oracle: spec iverilog@13.0
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_foreach_dynamic_resize_undefined.expected
*/
module test_foreach_dynamic_resize_undefined;
  int stable[], growing[], shrinking[];
  string stable_indices = "", growth_indices = "", shrink_indices = "";

  initial begin
    stable = new[3];
    foreach (stable[i])
      stable_indices = {stable_indices, $sformatf("%0d", i)};
    $display("stable=%s", stable_indices);

    // Record indices without using them to access either resized array.
    if ($test$plusargs("observe_growth")) begin
      growing = new[2];
      foreach (growing[i]) begin
        growth_indices = {growth_indices, $sformatf(" %0d", i)};
        if (i == 0)
          growing = new[4](growing);
      end
      $display("growth=%s", growth_indices);
    end
    if ($test$plusargs("observe_shrink")) begin
      shrinking = new[4];
      foreach (shrinking[i]) begin
        shrink_indices = {shrink_indices, $sformatf(" %0d", i)};
        if (i == 0)
          shrinking = new[1](shrinking);
      end
      $display("shrink=%s", shrink_indices);
    end
    $finish(0);
  end
endmodule
