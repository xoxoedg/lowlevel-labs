//Microsoft ABI
int __attribute__((ms_abi)) alg(int n)
{
    if (n <= 1)
        return 1;
    return n * alg(n-1);
}

