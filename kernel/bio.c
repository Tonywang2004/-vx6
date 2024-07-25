// Buffer cache.
//
// The buffer cache is a linked list of buf structures holding
// cached copies of disk block contents.  Caching disk blocks
// in memory reduces the number of disk reads and also provides
// a synchronization point for disk blocks used by multiple processes.
//
// Interface:
// * To get a buffer for a particular disk block, call bread.
// * After changing buffer data, call bwrite to write it to disk.
// * When done with the buffer, call brelse.
// * Do not use the buffer after calling brelse.
// * Only one process at a time can use a buffer,
//     so do not keep them longer than necessary.


#include "types.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "riscv.h"
#include "defs.h"
#include "fs.h"
#include "buf.h"

#define NBUFMAP_BUCKET 13
#define BUFMAP_HASH(dev, blockno) ((((dev)<<27)|(blockno))%NBUFMAP_BUCKET)

struct {
  struct buf buf[NBUF];

  struct buf bufmap[NBUFMAP_BUCKET];
  struct spinlock bufmap_locks[NBUFMAP_BUCKET];
} bcache;


static inline void
bufmap_insert(uint key, struct buf *b) {
  b->next = bcache.bufmap[key].next;
  bcache.bufmap[key].next = b;
}

void
binit(void)
{
  //init bufmap
  for(int i=0;i<NBUFMAP_BUCKET;i++) {
    initlock(&bcache.bufmap_locks[i], "bcache_bufmap");
    bcache.bufmap[i].next = 0;
  }

  //init buffers
  for(int i=0;i<NBUF;i++){
    struct buf *b = &bcache.buf[i];
    initsleeplock(&b->lock, "buffer");
    b->valid = 0;
    b->trash = 1; 
    b->lastuse = 0;
    b->refcnt = 0;
    bufmap_insert(i%NBUFMAP_BUCKET, b);
  }
}

static inline struct buf*
bufmap_search(uint key, uint dev, uint blockno) {
  struct buf *b;
  for(b = bcache.bufmap[key].next; b; b = b->next){
    if(b->dev == dev && b->blockno == blockno && !b->trash){
      return b;
    }
  }
  return 0;
}

// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
  struct buf *b;

  uint key = BUFMAP_HASH(dev, blockno);

  // printf("dev: %d, blockno: %d, locked: %d\n", dev, blockno, bcache.bufmap_locks[key].locked);
  
  acquire(&bcache.bufmap_locks[key]);

  // Is the block already cached?
  if((b = bufmap_search(key, dev, blockno))) {
    b->refcnt++;
    release(&bcache.bufmap_locks[key]);
    acquiresleep(&b->lock);
    return b;
  }

  release(&bcache.bufmap_locks[key]);

  struct buf *before_least = 0; 
  uint holding_bucket = -1;
  for(int i = 0; i < NBUFMAP_BUCKET; i++){
    acquire(&bcache.bufmap_locks[i]);
    int newfound = 0; 
    for(b = &bcache.bufmap[i]; b->next; b = b->next) {
      if((b->trash || b->next->refcnt == 0) && (!before_least || b->next->lastuse < before_least->next->lastuse)) {
        before_least = b;
        newfound = 1;
      }
    }
    if(!newfound) {
      release(&bcache.bufmap_locks[i]);
    } else {
      if(holding_bucket != -1) release(&bcache.bufmap_locks[holding_bucket]);
      holding_bucket = i;
    }
  }
  if(!before_least) {
    panic("bget: no buffers");
  }
  struct buf *newb;
  newb = before_least->next;
  
  if(holding_bucket != key) {
    // remove the buf from it's original bucket
    before_least->next = newb->next;
    release(&bcache.bufmap_locks[holding_bucket]);

    // reacquire blockno's bucket lock, for later insertion
    acquire(&bcache.bufmap_locks[key]);
  }

  if((b = bufmap_search(key, dev, blockno))){
    b->refcnt++;

    if(holding_bucket != key) {
      newb->trash = 1;
      newb->lastuse = 0; // so it will be evicted and re-used earlier.

      bufmap_insert(key, newb);
    }
    release(&bcache.bufmap_locks[key]);
    acquiresleep(&b->lock);
    return b;
  }
  if(holding_bucket != key) {
    bufmap_insert(key, newb);
  }
  
  newb->trash = 0; 
  newb->dev = dev;
  newb->blockno = blockno;
  newb->refcnt = 1;
  newb->valid = 0;
  release(&bcache.bufmap_locks[key]);
  acquiresleep(&newb->lock);
  return newb;
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
	virtio_disk_rw(b, 1);
}

// Release a locked buffer.
void
brelse(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("brelse");

  releasesleep(&b->lock);

  uint key = BUFMAP_HASH(b->dev, b->blockno);

  acquire(&bcache.bufmap_locks[key]);
  b->refcnt--;
  if (b->refcnt == 0) {
    b->lastuse = ticks;
  }
  release(&bcache.bufmap_locks[key]);
}

void
bpin(struct buf *b) {
  uint key = BUFMAP_HASH(b->dev, b->blockno);

  acquire(&bcache.bufmap_locks[key]);
  b->refcnt++;
  release(&bcache.bufmap_locks[key]);
}

void
bunpin(struct buf *b) {
  uint key = BUFMAP_HASH(b->dev, b->blockno);

  acquire(&bcache.bufmap_locks[key]);
  b->refcnt--;
  release(&bcache.bufmap_locks[key]);
}

