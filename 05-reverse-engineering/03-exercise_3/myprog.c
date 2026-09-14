//defines _exit
//Microsoft ABI
#include <unistd.h>

int __attribute__((ms_abi)) alg(int n);
int my_var1 = 0xAB;


int my_entry(void)
{
    int my_var2 = 3;
    for (int i = 0; i < 6; ++i)
    {
        _exit(my_var1 + my_var2 + alg(i));
    }
	
}
