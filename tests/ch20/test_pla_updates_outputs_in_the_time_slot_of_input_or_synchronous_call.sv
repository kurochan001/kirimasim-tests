/*
:name: test_pla_updates_outputs_in_the_time_slot_of_input_or_synchronous_call
:description: Asynchronous PLA outputs follow input and personality changes without delay and synchronous outputs wait for a call
:tags: ch20
:type: simulation
:lrm: 1800-2023 20.16.1 20.16
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_pla_updates_outputs_in_the_time_slot_of_input_or_synchronous_call.expected
*/
`timescale 1ns/1ns
module test_pla_updates_outputs_in_the_time_slot_of_input_or_synchronous_call;
  logic [0:1] personality[0:1];
  logic [0:1] input_terms;
  logic async_first, async_second, sync_first, sync_second;
  string async_trace = "", sync_trace = "";

  always @(async_first or async_second) if ($time >= 10)
    async_trace = {async_trace, $sformatf(" %0d:%b%b", $time, async_first, async_second)};
  always @(sync_first or sync_second) if ($time >= 10)
    sync_trace = {sync_trace, $sformatf(" %0d:%b%b", $time, sync_first, sync_second)};

  initial begin
    personality[0] = 2'b10;
    personality[1] = 2'b11;
    input_terms = 2'b10;
    $async$and$array(personality, input_terms, {async_first, async_second});
    $sync$and$array(personality, input_terms, {sync_first, sync_second});
    #10 input_terms = 2'b01;
    #5 $sync$and$array(personality, input_terms, {sync_first, sync_second});
    #10 personality[1] = 2'b01;
    #5 $sync$and$array(personality, input_terms, {sync_first, sync_second});
    #10 $display("async:%s", async_trace);
    $display("sync:%s", sync_trace);
  end
endmodule
