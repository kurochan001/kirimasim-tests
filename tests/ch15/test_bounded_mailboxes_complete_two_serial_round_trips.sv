/*
:name: test_bounded_mailboxes_complete_two_serial_round_trips
:description: Two serial request and reply exchanges complete on bounded mailboxes (IEEE 1800-2023 Section 15.4.5)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4.5 15.4.3 9.3.2
:oracle: spec verilator@5.054
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_bounded_mailboxes_complete_two_serial_round_trips.expected
:expected_exit: 0
*/
// Each get has a matching put. The delay separates the two replies. Only the
// final summary is observed, so process order within a time slot does not
// affect the oracle.

module test_bounded_mailboxes_complete_two_serial_round_trips;
  class exchange;
    mailbox #(int) requests = new(1);
    mailbox #(string) replies = new(1);
    int first_request, second_request;
    string first_reply, second_reply;

    task run();
      fork
        begin
          requests.put(11);
          replies.get(first_reply);
          requests.put(22);
          replies.get(second_reply);
        end
        begin
          requests.get(first_request);
          #1;
          replies.put("first");
          requests.get(second_request);
          #1;
          replies.put("second");
        end
      join
      $display("CHECK %0d %0d %s %s", first_request, second_request, first_reply, second_reply);
    endtask
  endclass

  initial begin
    automatic exchange pair = new;
    pair.run();
    $finish;
  end
  initial begin
    #40;
    $fatal(1, "second exchange did not complete");
  end
endmodule
