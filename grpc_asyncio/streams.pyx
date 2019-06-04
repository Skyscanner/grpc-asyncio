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
    def is_data_available(self, n):
        """
        Check if there is n length data in the buffer
        """
        if len(self._buffer) >= n:
            return True

        return False
