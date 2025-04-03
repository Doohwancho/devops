import http from 'k6/http';
import { sleep } from 'k6';

export const options = {
  stages: [
    { duration: '10s', target: 100 },
    { duration: '30s', target: 200 },
    { duration: '1m', target: 400 },
    { duration: '2m', target: 600 },
    { duration: '2m', target: 800 },
    { duration: '2m', target: 1000 },
    { duration: '10s', target: 0 }
  ],
};

export default function () {
  // 테스트할 URL 입력
  // http.get('http://127.0.0.1:80');
  http.get('http://host.docker.internal:80');
  sleep(1);
}

