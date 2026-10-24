/*
:name: test_std_package_implicit_import
:description: the names of the built-in package std are visible everywhere through its implicit wildcard import, a user declaration can hide one of them, std:: still reaches it, and its functions are called without a dollar sign (IEEE 1800-2023 Section 26.7)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.7 18.12 15.4
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_std_package_implicit_import.expected
*/
// IEEE 1800-2023 §26.7: the built-in package std is wildcard imported into
// the compilation-unit scope of every compilation unit, so its declarations
// can be used anywhere without a qualifier unless user code declares the
// same name; std:: always reaches the built-in declaration; and its tasks
// and functions are called without a leading $.
// The module declares its own type named mailbox (an int), so mailbox
// there means that type, while std::mailbox is still the built-in class
// (§15.4), used to pass the value 7. The type semaphore is used without a
// qualifier. The scope randomize function (§18.12) is called once as
// std::randomize and once as plain randomize, each with a constraint that
// fixes the result.

module test_std_package_implicit_import;
  typedef int mailbox;
  mailbox count = 5;
  std::mailbox #(int) q = new();
  semaphore key = new(2);
  int got, x, y;

  initial begin
    q.put(7);
    q.get(got);
    void'(std::randomize(x) with { x == 11; });
    void'(randomize(y) with { y == 12; });
    $display("count=%0d got=%0d x=%0d y=%0d key taken: %0d", count, got, x, y,
             key.try_get(2) > 0);
  end
endmodule
