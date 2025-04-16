import unittest
from app.hello_server import HelloHandler
from unittest.mock import MagicMock
from io import BytesIO


class TestHelloHandler(unittest.TestCase):
    def setUp(self):
        # Create mock socket and response
        self.request = MagicMock()
        self.request.makefile.return_value = BytesIO()

        self.client_address = ('127.0.0.1', 12345)
        self.server = MagicMock()

        # Create mock output stream
        self.output = BytesIO()
        self.handler = HelloHandler(self.request, self.client_address, self.server)
        self.handler.wfile = self.output

    def test_get_response(self):
        # Mock methods used internally
        self.handler.send_response = MagicMock()
        self.handler.send_header = MagicMock()
        self.handler.end_headers = MagicMock()

        self.handler.do_GET()

        self.handler.send_response.assert_called_with(200)
        self.handler.send_header.assert_called_with('Content-type', 'text/plain')
        self.handler.end_headers.assert_called()

        self.output.seek(0)
        response = self.output.read()
        self.assertEqual(response, b'Hello From Szymon (CI_ID=unknown)')

if __name__ == '__main__':
    unittest.main()
