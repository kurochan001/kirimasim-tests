/*
:name: test_constraint_function_priority_does_not_prune_high_randc_cycle
:description: A cyclic function argument is solved without lower constraints that can accept only one of its cycle values
:tags: ch18
:type: simulation
:lrm: 1800-2023 18.5.11 18.4.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_constraint_function_priority_does_not_prune_high_randc_cycle.expected
*/
class partitioned_choice;
  randc bit cyc;
  rand bit result;

  function automatic bit identity(bit value);
    return value;
  endfunction

  constraint higher { cyc inside {0, 1}; }
  constraint lower { result == identity(cyc); result == 0; }
endclass

class joint_choice;
  randc bit cyc;
  rand bit result;

  constraint higher { cyc inside {0, 1}; }
  constraint lower { result == cyc; result == 0; }
endclass

class isolated_cycle;
  randc bit cyc;
  constraint higher { cyc inside {0, 1}; }
endclass

class lower_cycle;
  rand bit argument, result;
  randc bit cyc;

  function automatic bit identity(bit value);
    return value;
  endfunction

  constraint higher { argument == 1; }
  constraint lower { result <= identity(argument); (cyc == 0) -> (result == 0); }
endclass

module test_constraint_function_priority_does_not_prune_high_randc_cycle;
  partitioned_choice partitioned = new;
  joint_choice joint = new;
  isolated_cycle high_only = new;
  lower_cycle low = new;

  initial begin
    bit partition_first, partition_second, joint_first, joint_second;
    bit high_first, high_second, high_start;
    bit low_first, low_second, low_start;
    automatic int bad = 0;

    // If the first call succeeds it consumed zero from the high-priority
    // cycle. The next high-priority value is one, which the lower set cannot
    // satisfy. If the first call fails, it has already exposed the split.
    partition_first = partitioned.randomize();
    if (partition_first && (partitioned.cyc != 0 || partitioned.result != 0)) bad++;
    partition_second = partitioned.randomize();
    if (partition_second && (partitioned.cyc != 0 || partitioned.result != 0)) bad++;

    // Without the function partition, the feasible cyclic set is {0}.
    joint_first = joint.randomize();
    if (joint_first && (joint.cyc != 0 || joint.result != 0)) bad++;
    joint_second = joint.randomize();
    if (joint_second && (joint.cyc != 0 || joint.result != 0)) bad++;

    high_first = high_only.randomize();
    high_start = high_only.cyc;
    high_second = high_only.randomize();
    // The high argument stays fixed for both calls. Both lower cyclic
    // values have a compatible result, so they complete one permutation.
    low_first = low.randomize();
    low_start = low.cyc;
    if (low_first && (low.argument != 1 || (!low.cyc && low.result))) bad++;
    low_second = low.randomize();
    if (low_second && (low.argument != 1 || (!low.cyc && low.result))) bad++;

    $display("partition both=%b joint both=%b isolated cycle=%b bad solutions=%0d",
             partition_first && partition_second, joint_first && joint_second,
             high_first && high_second && high_start != high_only.cyc, bad);
    $display("lower cycle=%b", low_first && low_second && low_start != low.cyc);
  end
endmodule
