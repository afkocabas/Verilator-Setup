#include <print>
#define FIFO_TESTBENCH_IMPLEMENTATION
#include "AsyncFIFO.hh"

enum class STATUS { SUCCESS = 0, FAIL = 1 };

// Function declarations
STATUS test_reset(FIFO_TestBench& fb);
STATUS test_single_read(FIFO_TestBench& fb);
STATUS test_single_write(FIFO_TestBench& fb, FIFO_ITEM item);
STATUS test_fill_until_full(FIFO_TestBench& fb);
STATUS test_drain_until_empty(FIFO_TestBench& fb);

STATUS test_reset(FIFO_TestBench& fb) {
  fb.reset();
  fb.expect_empty();
  fb.expect_full(0);

  std::println("It passed the reset test.");
  return STATUS::SUCCESS;
}

int main(int argc, char* argv[]) {
  FIFO_TestBench fb;
  test_reset(fb);
  return 0;
}
