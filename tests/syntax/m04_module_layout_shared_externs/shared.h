/* Objects one unit defines and other units take the address of. */
typedef struct {
    int (*step)(int);
    int next;
} state_t;

extern int counter;
extern int values[4];
extern state_t states[4];
extern int *cursor;

int twice(int v);
int plus_one(int v);
int run_states(int v);
