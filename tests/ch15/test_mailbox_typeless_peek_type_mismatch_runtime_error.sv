/*
:name: test_mailbox_typeless_peek_type_mismatch_runtime_error
:description: peek() on a mailbox without a type parameter gives a run-time error when the type of its variable is not equivalent to the type of the message (IEEE 1800-2023 Section 15.4.7)
:tags: ch15
:type: simulation
:lrm: 1800-2023 15.4.7 15.4.9 6.22.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_mailbox_typeless_peek_type_mismatch_runtime_error.expected
:expected_stderr_regex: (?i:\berror\b)
*/
// IEEE 1800-2023 §15.4.7: when the type of the variable given to peek() is
// not equivalent to the type of the message in the mailbox, a run-time error
// is generated. §15.4.9: a mailbox declared without a type parameter is
// typeless and carries messages of any type, so the check is one of the
// run. The mailbox first holds an int message, and peek() with an int
// variable is legal: the message is copied and gives 7, and a get() then
// takes it out.
// Then a message is put under a condition that only the run knows; it is a
// string, and peek() with the int variable shall give the error (§6.22.2:
// string and int are not equivalent). The mailbox is not empty, so the call
// does not block. The standard does not say what the call does with the
// message or the variable after the error or whether the run goes on, so
// nothing is printed after it; the messages of the run are checked for an
// error, whose form the standard leaves to the tool. An implementation that
// converts the string to an int reports no error and fails that check.
// Icarus Verilog 13.0 does not support mailboxes, and Verilator 5.052 does not
// support a mailbox without a type parameter.

module test_mailbox_typeless_peek_type_mismatch_runtime_error;
  mailbox m = new();
  int n = 7, i, k;
  string word = "hi";

  initial begin
    m.put(n);
    m.peek(i);
    m.get(i);
    $display("int message, int variable: %0d, num=%0d", i, m.num());
    k = 1 + 1;
    if (k == 2) m.put(word);
    else m.put(n);
    $display("calling peek with an int variable for a string message");
    m.peek(i);
  end
endmodule
