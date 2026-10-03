# Lab 1: Demand Paging with `mmap`

## Question

Does `mmap` allocate physical memory right away, or only on access?

**Short answer:** Only on access. `mmap` merely reserves virtual address space. Physical frames are assigned page by page on first access, each one triggered by a page fault.

## Background

- **VmSize:** Size of the reserved virtual address space. Pure kernel bookkeeping, no RAM.
- **VmRSS:** The part of it that has physical frames entered in the page table, i.e. actual RAM usage.
- **Page fault:** The MMU finds no valid page table entry for a page. The CPU traps into the kernel, which grabs a frame, fills it with zeros, enters the page → frame mapping, and the instruction is retried.

## Setup

The program (`lab1.c`):

1. maps 1 GB of anonymous memory (`MAP_PRIVATE | MAP_ANONYMOUS`),
2. waits at **breakpoint 1** (mapped, nothing touched),
3. writes exactly 1 byte into every page,
4. waits at **breakpoint 2** (every page touched).

Key numbers:

|Quantity|Value|
|---|---|
|Mapped region|1 GB = 1,073,741,824 bytes = 1,048,576 kB|
|Page size|4096 bytes|
|Number of pages|1,073,741,824 / 4096 = 262,144|

The loop that touches every page once:

c

```c
int count_loops = SIZE / 4096;
size_t page_offset = 0;
for (int i = 0; i < count_loops; i++) {
    p[page_offset] = 0;   // 1 byte, first byte of the page
    page_offset += 4096;
}
```

One byte per page is enough, because a page fault is triggered per page, not per byte.

## Prediction

||Breakpoint 1|Breakpoint 2|
|---|---|---|
|VmSize|approx. 1 GB|unchanged|
|VmRSS|a few MB (just the program itself)|approx. 1 GB more|

Page faults in the loop: approx. 262,144, one per page.

## Running it


```sh
gcc -O0 -o lab1 lab1.c
./lab1
```

Measure in a second terminal at both breakpoints:


```sh
grep -E 'VmSize|VmRSS' /proc/$(pgrep lab1)/status
```

Page faults and timing in a separate run (press Enter twice):

```sh
/usr/bin/time -v ./lab1
```

## Results

||Breakpoint 1|Breakpoint 2|
|---|---|---|
|VmSize|1,051,268 kB|TODO: measure|
|VmRSS|1,050,248|TODO: measure|

From `/usr/bin/time -v`:

|Metric|Value|
|---|---|
|Minor page faults|262,220|
|Major page faults|0|
|Maximum resident set size|1,050,216 kB|
|User time|0.03 s|
|System time|0.35 s|

## Explanation

**Breakpoint 1:** VmSize already contains the full GB (1,048,576 kB) plus roughly 2,700 kB for the program, libc and stack. VmRSS is only 1,672 kB, so not a single page of the mapped region is in RAM. `mmap` only created an entry in the kernel's bookkeeping; the page table is empty for that region.