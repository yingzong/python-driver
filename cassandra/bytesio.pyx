# -- cython: profile=True

cdef class BytesIOReader:
    """
    This class provides efficient support for reading bytes from a 'bytes' buffer,
    by returning char * values directly without allocating intermediate objects.
    """

    def __init__(self, bytes buf):
        self.buf = buf
        self.size = len(buf)
        self.buf_ptr = self.buf

    cdef char *read(self, Py_ssize_t n = -1) except NULL:
        """Read at most size bytes from the file
        (less if the read hits EOF before obtaining size bytes).

        If the size argument is negative or omitted, read all data until EOF
        is reached. The bytes are returned as a string object. An empty
        string is returned when EOF is encountered immediately.
        """
        cdef Py_ssize_t newpos = self.pos + n
        if n < 0:
            newpos = self.size
        elif newpos > self.size:
            # Raise an error here, as we do not want the caller to consume past the
            # end of the buffer
            raise EOFError("Cannot read past the end of the file")

        cdef char *res = self.buf_ptr + self.pos
        self.pos = newpos
        return res
