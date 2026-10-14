/*
:name: test_array_element_noop_nba_keeps_override_order
:description: Nonblocking assignments to one array element keep their order, also when one assigns the current value
:tags: ch4
:type: simulation
:lrm: 1800-2023 4.6 10.4.2
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_array_element_noop_nba_keeps_override_order.expected
*/
// Nonblocking assignments to one array element take effect in the order
// they were executed. Assigning an element its current value changes
// nothing, but it still overrides an earlier nonblocking assignment to the
// same element in the same time step.
//
// IEEE 1800-2023 4.6, 10.4.2

module top;
  logic clk = 1'b0;
  logic [7:0] arr[2];

  always #1 clk = ~clk;

  initial begin
    arr[0] = 8'h12;
    arr[1] = 8'h34;

    @(posedge clk);
    arr[0] <= arr[0];
    arr[1] <= arr[1];

    @(posedge clk);
    if (arr[0] !== 8'h12 || arr[1] !== 8'h34) begin
      $display("TEST FAILED: no-op array NBA changed values arr0=%h arr1=%h", arr[0], arr[1]);
      $fatal(1);
    end

    arr[0] <= 8'h5a;
    arr[0] <= arr[1];

    @(posedge clk);
    if (arr[0] !== 8'h34) begin
      $display("TEST FAILED: pending array NBA ordering lost arr0=%h", arr[0]);
      $fatal(1);
    end

    $display("TEST PASSED: nonblocking assignments to an array element kept their order");
    $finish;
  end
endmodule
