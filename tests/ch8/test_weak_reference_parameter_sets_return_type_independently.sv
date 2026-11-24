/*
:name: test_weak_reference_parameter_sets_return_type_independently
:description: Two weak-reference specializations use their own class types for the returned handles
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.30.1 G.7
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_weak_reference_parameter_sets_return_type_independently.expected
*/
module test_weak_reference_parameter_sets_return_type_independently;
  class alpha;
    int value = 31;
  endclass
  class beta;
    bit [7:0] payload = 8'hb7;
  endclass

  initial begin
    alpha first, recovered_first;
    beta second, recovered_second;
    std::weak_reference #(alpha) first_ref;
    std::weak_reference #(beta) second_ref;
    first = new;
    second = new;
    first_ref = new(first);
    second_ref = new(second);
    recovered_first = first_ref.get();
    recovered_second = second_ref.get();
    $display("typed objects=%0d/%h same=%0d/%0d",
             recovered_first.value, recovered_second.payload,
             recovered_first == first, recovered_second == second);
  end
endmodule
