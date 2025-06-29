#!/usr/bin/env python3
"""
Простой тестовый сервер для проверки universal links
Запустите: python3 test_server.py
"""

from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os

class TestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/.well-known/apple-app-site-association':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            
            response = {
                "applinks": {
                    "apps": [],
                    "details": [
                        {
                            "appID": "TEAM_ID.com.example.acti_mobile",
                            "paths": [
                                "/event/*",
                                "/api/event/*"
                            ]
                        }
                    ]
                }
            }
            
            self.wfile.write(json.dumps(response, indent=2).encode())
            
        elif self.path == '/.well-known/assetlinks.json':
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            
            response = [
                {
                    "relation": ["delegate_permission/common.handle_all_urls"],
                    "target": {
                        "namespace": "android_app",
                        "package_name": "com.example.acti_mobile",
                        "sha256_cert_fingerprints": [
                            "SHA256_FINGERPRINT_HERE"
                        ]
                    }
                }
            ]
            
            self.wfile.write(json.dumps(response, indent=2).encode())
            
        elif self.path.startswith('/event/'):
            # Тестовая страница для universal links
            self.send_response(200)
            self.send_header('Content-Type', 'text/html')
            self.end_headers()
            
            event_id = self.path.split('/')[-1]
            html = f"""
            <!DOCTYPE html>
            <html>
            <head>
                <title>Event {event_id}</title>
                <meta name="viewport" content="width=device-width, initial-scale=1">
            </head>
            <body>
                <h1>Event {event_id}</h1>
                <p>Это тестовая страница для universal link</p>
                <p>Если приложение установлено, оно должно открыться автоматически</p>
                <p>Если нет, вы увидите эту страницу</p>
                <a href="acti://api.actiadmin.ru/event/{event_id}">Открыть в приложении (Deep Link)</a>
            </body>
            </html>
            """
            
            self.wfile.write(html.encode())
            
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b'Not Found')

if __name__ == '__main__':
    server = HTTPServer(('localhost', 8000), TestHandler)
    print('Тестовый сервер запущен на http://localhost:8000')
    print('Для тестирования universal links:')
    print('1. Откройте в браузере: http://localhost:8000/event/123')
    print('2. Или используйте ngrok для доступа с устройства:')
    print('   ngrok http 8000')
    print('   Затем откройте: https://your-ngrok-url.ngrok.io/event/123')
    server.serve_forever() 