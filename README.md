# DESnuts
Hello world! This is DESnuts - an implementation that will make the world a better place. 

# Intention
As [DES] (https://en.wikipedia.org/wiki/Data_Encryption_Standard) is only a 56-bit key, it is possible to crack it in a finite amount of time. Currently the repo has two implementations provided, one is on FPGA, another is on CUDA. The CUDA code is guarenteed correctness, and will take approximately 128 years to crack DES.

# Implementation
FPGA used Verlog, with the S-box implementation. CUDA used.. CUDA (C/C++) implemented the traditional DES algorithm, without the S-box.

# Contributor
All We Human

