options gen2

struct event_queue_t {
    waiter : int
}
def event_queues_init(var queues : event_queue_t?) {
    unsafe {
        queues[0].waiter = 42
    }
}
