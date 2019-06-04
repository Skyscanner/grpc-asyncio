import asyncio


async def open_connection(
        host=None, port=None, *, loop=None, limit=2 ** 16, **kwargs):

    if loop is None:
        loop = asyncio.get_event_loop()
    reader = StreamReader(limit=limit, loop=loop)
    protocol = asyncio.StreamReaderProtocol(reader, loop=loop)
    transport, _ = await loop.create_connection(
        lambda: protocol, host, port, **kwargs)
    writer = asyncio.StreamWriter(transport, protocol, reader, loop)
    return reader, writer


class StreamReader(asyncio.StreamReader):
    async def read(self, n=-1):
        if self._exception is not None:
            raise self._exception

        if n == 0:
            return b''

        if n < 0:
            # This used to just loop creating a new waiter hoping to
            # collect everything in self._buffer, but that would
            # deadlock if the subprocess sends more than self.limit
            # bytes.  So just call self.read(self._limit) until EOF.
            blocks = []
            while True:
                block = await self.read(self._limit)
                if not block:
                    break
                blocks.append(block)
            return b''.join(blocks)

        if not self._buffer and not self._eof:
            await self._wait_for_data('read')

        # This will work right even if buffer is less than n bytes
        data = bytes(self._buffer[:n])
        del self._buffer[:n]

        self._maybe_resume_transport()
        return data

    def is_data_available(self, n):
        """
        Check if there is n length data in the buffer
        """
        if len(self._buffer) >= n:
            return True

        return False
