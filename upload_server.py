import http.server
import socketserver
import cgi
import os

PORT = 8000

class FileUploadHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/upload.html':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            html = """
            <html><body>
            <form enctype="multipart/form-data" method="post" action="/upload">
            <input type="file" name="file" />
            <input type="submit" value="Upload" />
            </form>
            </body></html>
            """
            self.wfile.write(html.encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()

    def do_POST(self):
        if self.path == '/upload':
            form = cgi.FieldStorage(
                fp=self.rfile,
                headers=self.headers,
                environ={'REQUEST_METHOD': 'POST'}
            )
            file_field = form['file']
            if file_field.file:
                with open('godot/art/props/new_desk.jpg', 'wb') as f:
                    f.write(file_field.file.read())
                self.send_response(200)
                self.send_header('Content-type', 'text/html')
                self.end_headers()
                self.wfile.write(b"Success")
                print("UPLOAD_SUCCESSFUL")
            else:
                self.send_response(400)
                self.end_headers()

Handler = FileUploadHandler
with socketserver.TCPServer(("", PORT), Handler) as httpd:
    print("serving at port", PORT)
    httpd.serve_forever()
