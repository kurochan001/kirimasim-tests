/*
:name: test_disable_soft_preserves_distribution_weights
:description: Disabling an earlier soft equality frees the later distribution
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.13.2 18.5.3
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:top_module: test_disable_soft_preserves_distribution_weights
:expected_stdout: @test_disable_soft_preserves_distribution_weights.expected
*/
`timescale 1ns/1ns
module test_disable_soft_preserves_distribution_weights;
  localparam int DRAWS = 512;
`ifdef UNEQUAL_WEIGHTS
  localparam int EIGHT_WEIGHT = 7, MIN_FIVES = 25, MAX_FIVES = 108;
`else
  localparam int EIGHT_WEIGHT = 1, MIN_FIVES = 192, MAX_FIVES = 320;
`endif

  class retain_hint;
    rand int value;
    constraint earlier_hint { soft value == 5; }
    constraint weighted { soft value dist {5 := 1, 8 := EIGHT_WEIGHT}; }
  endclass

  class discard_hint;
    rand int value;
    constraint earlier_hint { soft value == 5; }
    constraint weighted {
      disable soft value;
      soft value dist {5 := 1, 8 := EIGHT_WEIGHT};
    }
  endclass

  class distribution_only;
    rand int value;
    constraint weighted { soft value dist {5 := 1, 8 := EIGHT_WEIGHT}; }
  endclass

  int fives[3], eights[3], unexpected;

  task automatic tally(int which, int value);
    case (value)
      5: fives[which]++;
      8: eights[which]++;
      default: unexpected++;
    endcase
  endtask

  function automatic bit weights_match(int which);
    return fives[which] inside {[MIN_FIVES:MAX_FIVES]}
        && fives[which] + eights[which] == DRAWS;
  endfunction

  initial begin
    automatic retain_hint retained = new;
    automatic discard_hint discarded = new;
    automatic distribution_only baseline = new;
    automatic int seed = 73;
    void'($value$plusargs("draw_seed=%d", seed));
    foreach (fives[i]) begin
      fives[i] = 0;
      eights[i] = 0;
    end
    unexpected = 0;
    retained.srandom(seed);
    discarded.srandom(seed);
    baseline.srandom(seed);
    repeat (DRAWS) begin
      if (!(retained.randomize() && discarded.randomize() && baseline.randomize()))
        $fatal(1, "could not solve a distribution");
      tally(0, retained.value);
      tally(1, discarded.value);
      tally(2, baseline.value);
    end
    $display("retained equality=%0d", fives[0] == DRAWS && eights[0] == 0);
    $display("discarded weights=%0d", weights_match(1));
    $display("baseline weights=%0d", weights_match(2));
    $display("unexpected=%0d", unexpected);
    if ($test$plusargs("observe_counts")) begin
      $display("weight for 8=%0d", EIGHT_WEIGHT);
      $display("retained: %0d %0d", fives[0], eights[0]);
      $display("discarded: %0d %0d", fives[1], eights[1]);
      $display("baseline: %0d %0d", fives[2], eights[2]);
    end
    $finish(0);
  end
endmodule
