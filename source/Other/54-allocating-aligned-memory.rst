Allocating aligned memory
=========================

- **Author or source:** Benno Senoner
- **Type:** memory allocation
- **Created:** 2002-01-17 03:08:46


.. code-block:: text
    :caption: notes

    we waste up to align_size + sizeof(int) bytes when we alloc a memory area.
    We store the aligned_ptr - unaligned_ptr delta in an int located before the aligned area.
    This is needed for the free() routine since we need to free all the memory not only the
    aligned area.
    You have to use aligned_free() to free the memory allocated with aligned_malloc() !


.. code-block:: c++
    :linenos:
    :caption: code

    /* align_size has to be a power of two !! */
    void *aligned_malloc(size_t size, size_t align_size) {
    
      char *ptr,*ptr2,*aligned_ptr;
      int align_mask = align_size - 1;
    
      ptr=(char *)malloc(size + align_size + sizeof(int));
      if(ptr==NULL) return(NULL);
    
      ptr2 = ptr + sizeof(int);
      aligned_ptr = ptr2 + (align_size - ((size_t)ptr2 & align_mask));
    
    
      ptr2 = aligned_ptr - sizeof(int);
      *((int *)ptr2)=(int)(aligned_ptr - ptr);
    
      return(aligned_ptr);
    }
    
    void aligned_free(void *ptr) {
    
      int *ptr2=(int *)ptr - 1;
      ptr -= *ptr2;
      free(ptr);
    }

