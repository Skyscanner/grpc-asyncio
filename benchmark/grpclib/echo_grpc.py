# Generated by the Protocol Buffers compiler. DO NOT EDIT!
# source: echo.proto
# plugin: grpclib.plugin.main
import abc

import grpclib.const
import grpclib.client

import echo_pb2


class EchoBase(abc.ABC):

    @abc.abstractmethod
    async def Hi(self, stream):
        pass

    def __mapping__(self):
        return {
            '/echo.Echo/Hi': grpclib.const.Handler(
                self.Hi,
                grpclib.const.Cardinality.UNARY_UNARY,
                echo_pb2.EchoRequest,
                echo_pb2.EchoReply,
            ),
        }


class EchoStub:

    def __init__(self, channel: grpclib.client.Channel) -> None:
        self.Hi = grpclib.client.UnaryUnaryMethod(
            channel,
            '/echo.Echo/Hi',
            echo_pb2.EchoRequest,
            echo_pb2.EchoReply,
        )
