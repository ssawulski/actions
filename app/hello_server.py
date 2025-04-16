from http.server import BaseHTTPRequestHandler, HTTPServer
import os

class HelloHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        
        ci_id = os.getenv("CI_ID", "unknown")

        message = f"Hello From Szymon (CI_ID={ci_id})"

        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(message.encode())

def run(server_class=HTTPServer, handler_class=HelloHandler, port=80):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print(f'Serving on port {port}...')
    httpd.serve_forever()

if __name__ == '__main__':
    run()
